set -euo pipefail

OUTPUT="*"
MPV_SOCK="${XDG_RUNTIME_DIR:-/tmp}/mpvpaper-wallpaper.sock"
STATE_FILE="$HOME/.local/state/wallpaper-select/current"
FALLBACK_IMG="$HOME/Pictures/Wallpapers/forro.jpg"

if [[ -f "$STATE_FILE" ]]; then
    kind="$(sed -n '1p' "$STATE_FILE")"
    path="$(sed -n '2p' "$STATE_FILE")"
else
    kind="image"
    path="$FALLBACK_IMG"
fi

if [[ "$kind" == "video" && -f "$path" ]]; then
    setsid mpvpaper -o "no-audio loop-file=inf hwdec=auto-safe input-ipc-server=${MPV_SOCK}" \
        "$OUTPUT" "$path" >/dev/null 2>&1 &
    disown
else
	#fall back
    [[ -f "$path" ]] || path="$FALLBACK_IMG"
    setsid awww-daemon >/dev/null 2>&1 &
    disown
    for _ in $(seq 1 40); do
        pgrep -f awww-daemon >/dev/null 2>&1 && break
        sleep 0.05
    done
    sleep 0.1
    [[ -f "$path" ]] && awww img "$path" >/dev/null 2>&1 || true
fi
