#!/usr/bin/env bash
set -euo pipefail

# =========================================================================
# CUSTOM SETUP (Define your layout and monitors here!)
# =========================================================================
DIRECTION="left-to-right"

MONITORS=(
    "HDMI-A-1|1920x1080|144|1"
    # "DP-1|1920x1080|60|1"
)

OUTPUT_FILE="$HOME/.config/niri/config/monitors.kdl"

# =========================================================================
# CORE FUNCTIONS (Do not touch this part unless you KNOW what you're doing)
# =========================================================================
generate_monitors_kdl() {
    local current_x=0
    local current_y=0
    local -a indices=()
    local i n="${#MONITORS[@]}"

    if [[ "$DIRECTION" == "right-to-left" || "$DIRECTION" == "bottom-to-top" ]]; then
        for (( i = n - 1; i >= 0; i-- )); do indices+=("$i"); done
    else
        for (( i = 0; i < n; i++ )); do indices+=("$i"); done
    fi

    : > "$OUTPUT_FILE"

    for i in "${indices[@]}"; do
        IFS='|' read -r output res hz scale <<< "${MONITORS[$i]}"
        local mode="${res}@${hz}"

        {
            echo "output \"$output\" {"
            echo "    mode \"$mode\""
            echo "    scale $scale"
            echo "    transform \"normal\""
            echo "    position x=$current_x y=$current_y"
            echo "}"
            echo
        } >> "$OUTPUT_FILE"

        local width height
        width="${res%x*}"
        height="${res#*x}"
        width=$(( width / scale ))
        height=$(( height / scale ))

        case "$DIRECTION" in
            left-to-right) current_x=$(( current_x + width )) ;;
            right-to-left) current_x=$(( current_x - width )) ;;
            top-to-bottom) current_y=$(( current_y + height )) ;;
            bottom-to-top) current_y=$(( current_y - height )) ;;
        esac
    done
}

generate_monitors_kdl

# sadly this is still in process, but will be further implemented on "PAW"! Check Paw's Client Repo!
