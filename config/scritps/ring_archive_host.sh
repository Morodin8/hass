#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

LOG="/config/scripts/ring_archive.log"
SOURCE_DIR="/config/www/ring"
ARCHIVE_DIR="/config/www/ring/archive"

MAX_LOG_LINES=1000
LOCKDIR="/tmp/ring_archive.lock"
MAX_FILES_PER_RUN=20
COUNT_FILE="/tmp/ring_archive_count"

# Timing
START_TS=$(date +%s)

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

get_host_load_averages() {
  set -- $(cut -d' ' -f1-3 /proc/loadavg)
  LOAD1="$1"
  LOAD5="$2"
  LOAD15="$3"
}

log_host_load() {
  get_host_load_averages
  log "Host load average (1m/5m/15m): $LOAD1 $LOAD5 $LOAD15"
}

get_effort_gauge() {
  load_int=$(awk "BEGIN { printf \"%d\", ($LOAD1 * 100) }")

  if [ "$load_int" -lt 50 ]; then
    EFFORT_LABEL="idle"
    EFFORT_GAUGE="[#----]"
  elif [ "$load_int" -lt 150 ]; then
    EFFORT_LABEL="light"
    EFFORT_GAUGE="[##---]"
  elif [ "$load_int" -lt 300 ]; then
    EFFORT_LABEL="moderate"
    EFFORT_GAUGE="[###--]"
  elif [ "$load_int" -lt 500 ]; then
    EFFORT_LABEL="busy"
    EFFORT_GAUGE="[####-]"
  else
    EFFORT_LABEL="heavy"
    EFFORT_GAUGE="[#####]"
  fi
}

acquire_lock() {
  if mkdir "$LOCKDIR" 2>/dev/null; then
    :
  else
    if [ -f "$LOCKDIR/pid" ]; then
      old_pid=$(cat "$LOCKDIR/pid" 2>/dev/null)

      if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
        log "WARNING: another archive run is already in progress (pid $old_pid), exiting"
        exit 0
      else
        log "WARNING: stale lock detected (pid ${old_pid:-unknown}), removing"
        rm -rf "$LOCKDIR"
        mkdir "$LOCKDIR" || exit 1
      fi
    else
      log "WARNING: lock directory exists without pid file, removing stale lock"
      rm -rf "$LOCKDIR"
      mkdir "$LOCKDIR" || exit 1
    fi
  fi

  echo "$$" > "$LOCKDIR/pid"
}

cleanup_lock() {
  rm -rf "$LOCKDIR"
  rm -f "$COUNT_FILE"
}

phase_preclean() {
  log "--- phase: pre-clean ---"

  find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.jpg" \) -size 0 -delete >> "$LOG" 2>&1

  find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.tmp.mp4" \) -mmin +30 -delete >> "$LOG" 2>&1
  find "$ARCHIVE_DIR" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.tmp.mp4" \) -mmin +30 -delete >> "$LOG" 2>&1
}

phase_archive() {
  log "--- phase: archive/compress ---"

  ELIGIBLE_COUNT=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -mmin +1440 | wc -l | tr -d ' ')

  if [ "$ELIGIBLE_COUNT" -gt "$MAX_FILES_PER_RUN" ]; then
    log "WARNING: $ELIGIBLE_COUNT eligible files found, limit=$MAX_FILES_PER_RUN"
  fi

  find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -mmin +1440 \
    -exec ls -1tr {} + 2>/dev/null | head -n "$MAX_FILES_PER_RUN" | \
  while read -r f; do
    [ -n "$f" ] || continue

    name="$(basename "$f")"
    base="${name%.mp4}"

    out="$ARCHIVE_DIR/$name"
    tmp="$ARCHIVE_DIR/${base}.tmp.mp4"
    jpg_src="$SOURCE_DIR/$base.jpg"
    jpg_dst="$ARCHIVE_DIR/$base.jpg"

    # Skip empty files
    if [ ! -s "$f" ]; then
      log "Removing zero-byte: $name"
      rm -f "$f"
      continue
    fi

    # If already archived, just move matching jpg if needed
    if [ -e "$out" ]; then
      if [ -f "$jpg_src" ] && [ ! -e "$jpg_dst" ]; then
        mv "$jpg_src" "$jpg_dst" 2>/dev/null && log "Moved snapshot to existing archive set: $base.jpg"
      fi
      continue
    fi

    # Quick validity check - skip clearly broken clips
    if ! ffmpeg -nostdin -v error -i "$f" -f null - >/dev/null 2>&1; then
      log "Skipping corrupt clip: $name"
      continue
    fi

    rm -f "$tmp"
    log "Compressing: $name"

    if ffmpeg -nostdin -y -i "$f" \
        -c:v libx264 -preset fast -crf 30 \
        -c:a aac -b:a 96k \
        "$tmp" >/dev/null 2>&1; then

      if [ -s "$tmp" ]; then
        if mv "$tmp" "$out"; then
          if rm -f "$f"; then
            [ -f "$jpg_src" ] && mv "$jpg_src" "$jpg_dst" 2>/dev/null

            count=$(cat "$COUNT_FILE")
            echo $((count + 1)) > "$COUNT_FILE"

            log "Success: $name"
          else
            log "WARNING: compressed but original not removed: $name"
          fi
        else
          log "ERROR: failed to move output: $name"
          rm -f "$tmp"
        fi
      else
        log "ERROR: empty output: $name"
        rm -f "$tmp"
      fi
    else
      log "ERROR: ffmpeg failed: $name"
      rm -f "$tmp"
    fi
  done

  REMAINING_COUNT=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -mmin +1440 | wc -l | tr -d ' ')
}

phase_retention() {
  log "--- phase: retention cleanup ---"

  find "$ARCHIVE_DIR" -maxdepth 1 -type f \
    \( -name "*.mp4" -o -name "*.jpg" \) \
    -mmin +40320 -delete >> "$LOG" 2>&1
}

phase_gallery() {
  log "--- phase: gallery rebuild ---"
  /bin/sh /config/scripts/ring_rebuild_galleries.sh >> "$LOG" 2>&1
}

phase_finish() {
  log "--- phase: finish ---"

  if [ -f "$LOG" ]; then
    tail -n "$MAX_LOG_LINES" "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
  fi

  END_TS=$(date +%s)
  DURATION=$((END_TS - START_TS))
  COMPRESSED_COUNT=$(cat "$COUNT_FILE")

  log_host_load
  get_effort_gauge

  log "Summary: queued=$ELIGIBLE_COUNT compressed=$COMPRESSED_COUNT remaining=$REMAINING_COUNT duration=${DURATION}s effort=$EFFORT_LABEL $EFFORT_GAUGE load=$LOAD1/$LOAD5/$LOAD15"
  log "=== host-side ring archive run finished ==="
  log "--------------------------------------------------"
}

# --- main ---

trap cleanup_lock EXIT INT TERM

mkdir -p "$SOURCE_DIR" "$ARCHIVE_DIR"
echo 0 > "$COUNT_FILE"

acquire_lock

log "=== host-side ring archive run started ==="
log_host_load

# check ffmpeg exists
if ! command -v ffmpeg >/dev/null 2>&1; then
  log "ERROR: ffmpeg not found"
  exit 1
fi

phase_preclean
phase_archive
phase_retention
phase_gallery
phase_finish
