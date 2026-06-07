#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

LOG="/config/scripts/ring_archive.log"
SOURCE_DIR="/media/ring"
ARCHIVE_DIR="/media/ring/archive"
CONTAINER="ffmpeg-ring"
MAX_LOG_LINES=1000
LOCKDIR="/tmp/ring_archive.lock"
MAX_FILES_PER_RUN=20

# Timing
START_TS=$(date +%s)

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

log_host_load() {
  set -- $(cut -d' ' -f1-3 /proc/loadavg)
  log "Host load average (1m/5m/15m): $1 $2 $3"
}

log_container_stats() {
  stats="$(docker stats --no-stream --format '{{.CPUPerc}} | {{.MemUsage}}' "$CONTAINER" 2>/dev/null || true)"
  if [ -n "$stats" ]; then
    log "Container stats ($CONTAINER): CPU/MEM $stats"
  else
    log "Container stats ($CONTAINER): unavailable"
  fi
}

# Prevent overlapping runs
if ! mkdir "$LOCKDIR" 2>/dev/null; then
  log "WARNING: another archive run is already in progress, exiting"
  exit 0
fi

cleanup_lock() {
  rmdir "$LOCKDIR" 2>/dev/null
}
trap cleanup_lock EXIT INT TERM

mkdir -p "$ARCHIVE_DIR"
log "=== host-side ring archive run started ==="
log_host_load
log_container_stats

# Check ffmpeg container is available
if ! docker exec "$CONTAINER" ffmpeg -version >/dev/null 2>&1; then
  log "ERROR: ffmpeg container '$CONTAINER' is not available"
  exit 1
fi

# 1) Clean zero-byte files in source
log "Cleaning zero-byte mp4 files in source"
find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -size 0 -print -delete >> "$LOG" 2>&1

# 2) Clean stale temp files in source/archive
log "Cleaning stale temp files"
find "$SOURCE_DIR" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.tmp.mp4" \) -mmin +30 -print -delete >> "$LOG" 2>&1
find "$ARCHIVE_DIR" -maxdepth 1 -type f \( -name "*.tmp" -o -name "*.tmp.mp4" \) -mmin +30 -print -delete >> "$LOG" 2>&1

# 3) Compress up to MAX_FILES_PER_RUN mp4 files older than 1 day
find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.mp4" -mmin +1440 -exec ls -1tr {} + 2>/dev/null | head -n "$MAX_FILES_PER_RUN" | while read -r f; do
  [ -n "$f" ] || continue

  name="$(basename "$f")"
  base="$(basename "$f" .mp4)"
  out="$ARCHIVE_DIR/${base}.mp4"
  tmp="$ARCHIVE_DIR/${base}.tmp.mp4"

  # Skip empty files
  if [ ! -s "$f" ]; then
    log "Removing zero-byte file during archive pass: $f"
    rm -f "$f"
    continue
  fi

  # Skip if archive already exists
  if [ -e "$out" ]; then
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

# 4) Delete archived mp4 files older than 4 weeks (28 days)
log "Cleaning archived mp4 files older than 28 days"
find "$ARCHIVE_DIR" -type f -name "*.mp4" -mmin +40320 -print -delete >> "$LOG" 2>&1

# 5) Trim log
if [ -f "$LOG" ]; then
  log "Trimming log to last $MAX_LOG_LINES lines"
  tail -n "$MAX_LOG_LINES" "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

END_TS=$(date +%s)
DURATION=$((END_TS - START_TS))

log_host_load
log_container_stats
log "=== host-side ring archive run finished (duration: ${DURATION}s, max files: ${MAX_FILES_PER_RUN}) ==="
log "--------------------------------------------------"
