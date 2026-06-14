#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CLIP="$1"
SOURCE="$2"

CURRENT_DIR="/config/www/ring"
ARCHIVE_DIR="/config/www/ring/archive"
KEEP_DIR="/config/www/ring/keep"

# Basic filename validation
case "$CLIP" in
  *[!A-Za-z0-9._-]*|'') exit 1 ;;
esac

case "$SOURCE" in
  current) SRC_DIR="$CURRENT_DIR" ;;
  archive) SRC_DIR="$ARCHIVE_DIR" ;;
  keep)    SRC_DIR="$KEEP_DIR" ;;
  *) exit 1 ;;
esac

mkdir -p "$KEEP_DIR"

MP4_SRC="$SRC_DIR/$CLIP.mp4"
JPG_SRC="$SRC_DIR/$CLIP.jpg"
MP4_DST="$KEEP_DIR/$CLIP.mp4"
JPG_DST="$KEEP_DIR/$CLIP.jpg"

# If already kept, do nothing
if [ "$SRC_DIR" = "$KEEP_DIR" ]; then
  exit 0
fi

[ -f "$MP4_SRC" ] && mv -f "$MP4_SRC" "$MP4_DST"
[ -f "$JPG_SRC" ] && mv -f "$JPG_SRC" "$JPG_DST"

exit 0
