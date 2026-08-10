set -euo pipefail

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
THEME="$HOME/.config/rofi/wallpaperPicker.rasi"
OUTPUT="*"
THUMB_SIZE="260x260"
MPV_SOCK="${XDG_RUNTIME_DIR:-/tmp}/mpvpaper-wallpaper.sock"
STATE_FILE="$HOME/.local/state/wallpaper-select/current"

IMG_EXT_RE='^(jpg|jpeg|png|webp|bmp|gif)$'
VID_EXT_RE='^(mp4|webm|mkv|mov|avi)$'

if command -v magick >/dev/null 2>&1; then
    IM_CMD="magick"
elif command -v convert >/dev/null 2>&1; then
    IM_CMD="convert"
else
    IM_CMD=""
fi

mkdir -p "$THUMB_DIR" "$(dirname "$STATE_FILE")"

kill_mpvpaper() {
    pkill -9 -f mpvpaper 2>/dev/null || true
    rm -f "$MPV_SOCK"
}

mpv_ipc_send() {
    [[ -S "$MPV_SOCK" ]] || return 1
    echo "$1" | socat - "UNIX-CONNECT:$MPV_SOCK" >/dev/null 2>&1
}

kill_awww_daemon() {
    pkill -9 -f awww-daemon 2>/dev/null || true
}

ensure_awww_daemon() {
    pgrep -f awww-daemon >/dev/null 2>&1 && return 0
    setsid awww-daemon --no-cache >/dev/null 2>&1 &
    disown
    sock="${XDG_RUNTIME_DIR:-/tmp}/awww-${WAYLAND_DISPLAY}.socket"
    for _ in $(seq 1 100); do
        [[ -S "$sock" ]] && return 0
        sleep 0.01
    done
}

declare -A path_of
declare -A thumb_of
menu=""

shopt -s nullglob nocaseglob
for file in "$WALLPAPER_DIR"/*; do
    [[ -f "$file" ]] || continue
    name="$(basename "$file")"
    ext="${name##*.}"
    ext="${ext,,}"

    if [[ "$ext" =~ $IMG_EXT_RE ]]; then
        kind="image"
    elif [[ "$ext" =~ $VID_EXT_RE ]]; then
        kind="video"
    else
        continue
    fi

    hash="$(printf '%s' "$file" | md5sum | cut -d' ' -f1)"
    thumb="$THUMB_DIR/$hash.png"

    if [[ ! -f "$thumb" ]]; then
        if [[ "$kind" == "image" ]]; then
            if [[ -n "$IM_CMD" ]]; then
                "$IM_CMD" "$file" -resize "${THUMB_SIZE}^" -gravity center \
                    -extent "$THUMB_SIZE" "$thumb" 2>/dev/null || cp "$file" "$thumb"
            else
                cp "$file" "$thumb"
            fi
        else
            ffmpeg -y -loglevel error -ss 00:00:01 -i "$file" -frames:v 1 \
                -vf "scale=${THUMB_SIZE//x/:}:force_original_aspect_ratio=increase,crop=${THUMB_SIZE//x/:}" \
                "$thumb" || continue
        fi
    fi

    path_of["$name"]="$file"
    thumb_of["$name"]="$thumb"
    menu+="${name}\0icon\x1f${thumb}\n"
done
shopt -u nullglob nocaseglob

if [[ -z "$menu" ]]; then
    notify-send "Wallpapers" "No files found in $WALLPAPER_DIR"
    exit 1
fi

selected="$(printf '%b' "$menu" | rofi -dmenu -i -show-icons -p "Wallpaper" -theme "$THEME")"
[[ -z "${selected:-}" ]] && exit 0

file="${path_of[$selected]:-}"
[[ -z "$file" ]] && exit 1

ext="${file##*.}"
ext="${ext,,}"

prev_kind="$(sed -n '1p' "$STATE_FILE" 2>/dev/null || true)"

if [[ "$ext" =~ $IMG_EXT_RE ]]; then
    ensure_awww_daemon
    if [[ "$prev_kind" == "video" ]]; then
        awww img "$file" --transition-type none
    else
        awww img "$file" --transition-type any --transition-duration 1
    fi
    wal -n -i "$file"
    kill_mpvpaper
    printf 'image\n%s\n' "$file" > "$STATE_FILE"
else
    if mpv_ipc_send "{ \"command\": [\"loadfile\", \"${file}\", \"replace\"] }"; then
        thumb="${thumb_of[$selected]:-}"
        [[ -n "$thumb" && -f "$thumb" ]] && wal -n -i "$thumb"
    else
        kill_mpvpaper
        setsid mpvpaper -o "no-audio loop-file=inf hwdec=auto-safe input-ipc-server=${MPV_SOCK}" \
            "$OUTPUT" "$file" >/dev/null 2>&1 &
        disown
        sleep 0.5
        thumb="${thumb_of[$selected]:-}"
        [[ -n "$thumb" && -f "$thumb" ]] && wal -n -i "$thumb"
        kill_awww_daemon
    fi
    printf 'video\n%s\n' "$file" > "$STATE_FILE"
fi
