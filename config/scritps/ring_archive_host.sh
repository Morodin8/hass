#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

LOG="/config/scripts/ring_archive.log"
SOURCE_DIR="/media/ring"
ARCHIVE_DIR="/media/ring/archive"
CONTAINER="ffmpeg-ring"
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

# Prevent overlapping runs
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  log "WARNING: another archive run is already in progress, exiting"
  exit 0
fi

cleanup_lock() {
  rmdir "$LOCKDIR" 2>/dev/null
  rm -f "$COUNT_FILE"
}
trap cleanup_lock EXIT INT TERM

mkdir -p "$ARCHIVE_DIR"
echo 0 > "$COUNT_FILE"

log "=== host-side ring archive run started ==="
log_host_load

# Check ffmpeg container is available
if ! docker exec "$CONTAINER" ffmpeg -version >/dev/null 2>&1; then
  log "ERROR: ffmpeg container '$CONTAINER' is not available"
  exit 1
fi

# 1) Clean zero-byte media files in source
log "Cleaning zero-byte media files in source"
find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.jpg" \) -size 0 -print -delete >> "$LOG" 2>&1

# 2) Clean stale temp files in source/archive
log "Cleaning stale temp files"
find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.tmp.mp4" \) -mmin +30 -print -delete >> "$LOG" 2>&1
find "$ARCHIVE_DIR" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.tmp.mp4" \) -mmin +30 -print -delete >> "$LOG" 2>&1

# 3) Count eligible videos older than 1 day
ELIGIBLE_COUNT=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -mmin +1440 | wc -l | tr -d ' ')

if [ "$ELIGIBLE_COUNT" -gt "$MAX_FILES_PER_RUN" ]; then
  log "WARNING: $ELIGIBLE_COUNT eligible files found, but max files per run is $MAX_FILES_PER_RUN. Remaining files will be processed in later runs."
fi

# 4) Compress up to MAX_FILES_PER_RUN oldest eligible videos
find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -mmin +1440 -exec ls -1tr {} + 2>/dev/null | head -n "$MAX_FILES_PER_RUN" | while read -r f; do
  [ -n "$f" ] || continue

  name="$(basename "$f")"
  base="$(basename "$f" .mp4)"
  out="$ARCHIVE_DIR/${base}.mp4"
  tmp="$ARCHIVE_DIR/${base}.tmp.mp4"
  jpg_src="$SOURCE_DIR/${base}.jpg"
  jpg_dst="$ARCHIVE_DIR/${base}.jpg"

  # Skip empty files
  if [ ! -s "$f" ]; then
    log "Removing zero-byte file during archive pass: $f"
    rm -f "$f"
    continue
  fi

  # If mp4 archive already exists, try to move matching jpg if needed
  if [ -e "$out" ]; then
    if [ -f "$jpg_src" ] && [ ! -e "$jpg_dst" ]; then
      if mv "$jpg_src" "$jpg_dst"; then
        log "Moved snapshot to existing archive set: $jpg_src -> $jpg_dst"
      else
        log "WARNING: failed to move snapshot: $jpg_src"
      fi
    fi
    log "Skipping (already exists): $out"
    continue
  fi

  rm -f "$tmp"
  log "Compressing: $f -> $out"

  if docker exec "$CONTAINER" ffmpeg \
      -y -i "/data/$name" \
      -c:v libx264 -preset fast -crf 30 \
      -c:a aac -b:a 96k \
      "/data/archive/${base}.tmp.mp4" >/dev/null 2>&1; then

    if [ -s "$tmp" ]; then
      if mv "$tmp" "$out"; then
        if rm -f "$f"; then
          log "Success: compressed and removed original: $f"

          if [ -f "$jpg_src" ]; then
            if mv "$jpg_src" "$jpg_dst"; then
              log "Moved snapshot: $jpg_src -> $jpg_dst"
            else
              log "WARNING: failed to move snapshot: $jpg_src"
            fi
          fi

          count=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
          count=$((count + 1))
          echo "$count" > "$COUNT_FILE"
        else
          log "WARNING: compressed but failed to remove original: $f"
        fi
      else
        log "ERROR: failed to move temp file into place: $tmp -> $out"
        rm -f "$tmp"
      fi
    else
      log "ERROR: output file empty: $tmp"
      rm -f "$tmp"
    fi
  else
    log "ERROR: ffmpeg failed: $f"
    rm -f "$tmp"
  fi
done

# 5) Count remaining eligible files after run
REMAINING_COUNT=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -mmin +1440 | wc -l | tr -d ' ')

# 6) Delete archived media older than 4 weeks (28 days)
log "Cleaning archived media older than 28 days"
find "$ARCHIVE_DIR" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.jpg" \) -mmin +40320 -print -delete >> "$LOG" 2>&1

# 7) Trim log
if [ -f "$LOG" ]; then
  log "Trimming log to last $MAX_LOG_LINES lines"
  tail -n "$MAX_LOG_LINES" "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

END_TS=$(date +%s)
DURATION=$((END_TS - START_TS))
COMPRESSED_COUNT=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)

log_host_load
get_effort_gauge
log "Summary: queued=${ELIGIBLE_COUNT} compressed=${COMPRESSED_COUNT} remaining=${REMAINING_COUNT} duration=${DURATION}s max=${MAX_FILES_PER_RUN} effort=${EFFORT_LABEL} ${EFFORT_GAUGE} load=${LOAD1}/${LOAD5}/${LOAD15}"
log "=== host-side ring archive run finished ==="
log "--------------------------------------------------"
