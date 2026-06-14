#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CURRENT_DIR="/config/www/ring"
ARCHIVE_DIR="/config/www/ring/archive"
KEEP_DIR="/config/www/ring/keep"

GALLERY_DIR="/config/www/ring-gallery"
CURRENT_HTML="$GALLERY_DIR/current.html"
ARCHIVE_HTML="$GALLERY_DIR/archive.html"
KEEP_HTML="$GALLERY_DIR/keep.html"
ALL_HTML="$GALLERY_DIR/all.html"

WEBHOOK_ID="ring_clip_action_d7075a15-5651-407d-b55c-10fd38582e1e"

mkdir -p "$GALLERY_DIR" "$CURRENT_DIR" "$ARCHIVE_DIR" "$KEEP_DIR"

human_size() {
  bytes="${1:-0}"
  awk -v b="$bytes" '
    function fmt(x) {
      split("B KB MB GB TB", u, " ")
      i = 1
      while (x >= 1024 && i < 5) {
        x /= 1024
        i++
      }
      if (i == 1) {
        return sprintf("%d %s", x, u[i])
      }
      return sprintf("%.1f %s", x, u[i])
    }
    BEGIN { print fmt(b) }
  '
}

folder_total_bytes() {
  folder="$1"
  find "$folder" -maxdepth 1 -type f -exec stat -c %s {} + 2>/dev/null | awk '{s += $1} END {print s + 0}'
}

folder_total_files() {
  folder="$1"
  find "$folder" -maxdepth 1 -type f | wc -l | tr -d ' '
}

folder_total_clips() {
  folder="$1"
  find "$folder" -maxdepth 1 -type f -name "*.mp4" | wc -l | tr -d ' '
}

write_html_head() {
  out_html="$1"
  title="$2"

  cat > "$out_html" <<EOF
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>$title</title>
  <style>
    body {
      margin: 0;
      padding: 10px;
      background: #0f1115;
      color: #e5e7eb;
      font-family: Arial, sans-serif;
    }

    .section {
      margin-bottom: 18px;
    }

    h2 {
      margin: 0 0 4px 0;
      font-size: 17px;
      font-weight: 600;
      color: #f3f4f6;
    }

    .summary {
      margin: 0 0 12px 0;
      color: #9ca3af;
      font-size: 12px;
      line-height: 1.3;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 10px;
    }

    .item {
      background: #161a20;
      border-radius: 10px;
      overflow: hidden;
      border: 1px solid #252a33;
    }

    .item a {
      text-decoration: none;
      color: inherit;
      display: block;
    }

    .thumb-wrap {
      position: relative;
      background: #000;
    }

    .thumb {
      width: 100%;
      aspect-ratio: 16 / 9;
      object-fit: cover;
      display: block;
      background: #000;
    }

    .thumb-fallback {
      width: 100%;
      aspect-ratio: 16 / 9;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #1c2430, #111827);
      color: #cbd5e1;
      font-size: 13px;
      font-weight: 600;
    }

    .badge {
      position: absolute;
      top: 8px;
      left: 8px;
      padding: 3px 7px;
      border-radius: 999px;
      font-size: 10px;
      font-weight: 700;
      line-height: 1;
      color: #fff;
      background: rgba(0, 0, 0, 0.55);
      backdrop-filter: blur(2px);
    }

    .badge.motion {
      background: rgba(37, 99, 235, 0.9);
    }

    .badge.ding {
      background: rgba(220, 38, 38, 0.9);
    }

    .play-icon {
      position: absolute;
      right: 8px;
      bottom: 8px;
      width: 28px;
      height: 28px;
      border-radius: 999px;
      background: rgba(0, 0, 0, 0.55);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      color: #fff;
    }

    .caption {
      padding: 8px 9px 4px;
      font-size: 12px;
      line-height: 1.3;
      color: #e5e7eb;
      word-break: break-word;
    }

    .meta {
      padding: 0 9px 8px;
      font-size: 11px;
      color: #9ca3af;
      line-height: 1.25;
    }

    .actions {
      display: flex;
      gap: 6px;
      padding: 0 9px 9px;
    }

    button {
      flex: 1;
      border: 0;
      border-radius: 8px;
      padding: 7px 8px;
      font-size: 11px;
      font-weight: 700;
      cursor: pointer;
    }

    .keep-btn {
      background: #166534;
      color: #fff;
    }

    .delete-btn {
      background: #b91c1c;
      color: #fff;
    }

    .keep-btn[disabled],
    .delete-btn[disabled] {
      opacity: 0.55;
      cursor: default;
    }

    .empty {
      padding: 12px;
      background: #161a20;
      border-radius: 10px;
      border: 1px solid #252a33;
      color: #9ca3af;
      font-size: 13px;
    }

    hr {
      border: 0;
      border-top: 1px solid #252a33;
      margin: 18px 0;
    }
  </style>
</head>
<body>
EOF
}

write_html_footer() {
  out_html="$1"

  cat >> "$out_html" <<EOF
  <script>
    async function clipAction(ev, action, clip, source, btn) {
      ev.preventDefault();
      ev.stopPropagation();

      const row = btn.closest('.item');
      const buttons = row.querySelectorAll('button');
      buttons.forEach(b => b.disabled = true);

      try {
        const res = await fetch('/api/webhook/$WEBHOOK_ID', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: action,
            clip: clip,
            source: source
          })
        });

        if (!res.ok) {
          throw new Error('Request failed: ' + res.status);
        }

        row.remove();
      } catch (e) {
        alert('Action failed: ' + e.message);
        buttons.forEach(b => b.disabled = false);
      }
    }
  </script>
</body>
</html>
EOF
}

append_gallery_section() {
  folder="$1"
  web_prefix="$2"
  out_html="$3"
  title="$4"
  source_name="$5"

  clip_count="$(folder_total_clips "$folder")"
  file_count="$(folder_total_files "$folder")"
  total_bytes="$(folder_total_bytes "$folder")"
  total_size="$(human_size "$total_bytes")"

  cat >> "$out_html" <<EOF
  <div class="section">
    <h2>$title</h2>
    <div class="summary">
      Clips: $clip_count • Files in folder: $file_count • Total size: $total_size
    </div>
    <div class="grid">
EOF

  found_any=0

  find "$folder" -maxdepth 1 -type f -name "*.mp4" | sort -r | while read -r mp4; do
    [ -n "$mp4" ] || continue

    found_any=1

    base="$(basename "$mp4" .mp4)"
    mp4_name="$(basename "$mp4")"
    jpg="$folder/$base.jpg"
    jpg_name="$(basename "$jpg")"

    mp4_bytes="$(stat -c %s "$mp4" 2>/dev/null || echo 0)"
    mp4_size="$(human_size "$mp4_bytes")"

    suffix="${base##*_}"
    if [ "$suffix" = "D" ]; then
      badge_text="Ding"
      badge_class="ding"
    else
      badge_text="Motion"
      badge_class="motion"
    fi

    if [ -f "$jpg" ]; then
      thumb_block="<img class=\"thumb\" src=\"$web_prefix/$jpg_name\" loading=\"lazy\">"
    else
      thumb_block="<div class=\"thumb-fallback\">No photo</div>"
    fi

    if [ "$source_name" = "keep" ]; then
      keep_button=""
    else
      keep_button="<button class=\"keep-btn\" onclick=\"clipAction(event, 'keep', '$base', '$source_name', this)\">Keep</button>"
    fi

    cat >> "$out_html" <<EOF
      <div class="item">
        <a href="$web_prefix/$mp4_name" target="_blank">
          <div class="thumb-wrap">
            $thumb_block
            <div class="badge $badge_class">$badge_text</div>
            <div class="play-icon">▶</div>
          </div>
          <div class="caption">$base</div>
          <div class="meta">$mp4_size</div>
        </a>
        <div class="actions">
          $keep_button
          <button class="delete-btn" onclick="clipAction(event, 'delete', '$base', '$source_name', this)">Delete</button>
        </div>
      </div>
EOF
  done

  if ! find "$folder" -maxdepth 1 -type f -name "*.mp4" | grep -q .; then
    cat >> "$out_html" <<EOF
      <div class="empty">No clips found.</div>
EOF
  fi

  cat >> "$out_html" <<EOF
    </div>
  </div>
EOF
}

# Individual pages
write_html_head "$CURRENT_HTML" "Ring - Current"
append_gallery_section "$CURRENT_DIR" "/local/ring" "$CURRENT_HTML" "Ring - Current" "current"
write_html_footer "$CURRENT_HTML"

write_html_head "$ARCHIVE_HTML" "Ring - Archive"
append_gallery_section "$ARCHIVE_DIR" "/local/ring/archive" "$ARCHIVE_HTML" "Ring - Archive" "archive"
write_html_footer "$ARCHIVE_HTML"

write_html_head "$KEEP_HTML" "Ring - Keep"
append_gallery_section "$KEEP_DIR" "/local/ring/keep" "$KEEP_HTML" "Ring - Keep" "keep"
write_html_footer "$KEEP_HTML"

# Combined page
write_html_head "$ALL_HTML" "Ring Gallery"
append_gallery_section "$CURRENT_DIR" "/local/ring" "$ALL_HTML" "Current" "current"
cat >> "$ALL_HTML" <<EOF
  <hr>
EOF
append_gallery_section "$ARCHIVE_DIR" "/local/ring/archive" "$ALL_HTML" "Archive" "archive"
cat >> "$ALL_HTML" <<EOF
  <hr>
EOF
append_gallery_section "$KEEP_DIR" "/local/ring/keep" "$ALL_HTML" "Keep" "keep"
write_html_footer "$ALL_HTML"
