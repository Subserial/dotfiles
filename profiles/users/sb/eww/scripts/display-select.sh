#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/eww_display_mode"

get_status() {
    # Check compositor directly for active mirror state
    if hyprctl monitors all 2>/dev/null | grep -A 25 "Monitor HDMI-A-1" | grep -qE "mirrorOf: *[0-9]+"; then
        echo "mirror"
    else
        echo "extend"
    fi
}

set_extend() {
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })' 2>/dev/null
    hyprctl eval 'hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "0x0", scale = 1, bitdepth = 8 })' 2>/dev/null
    # Clear mirror attribute
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75", position = "0x1080", scale = 1, bitdepth = 8, mirror = "" })' 2>/dev/null
    # Move odd workspaces to bottom monitor (HDMI-A-1), even to top monitor (DP-1)
    for ws in 1 3 5 7 9; do
        hyprctl eval "hl.dispatch(hl.dsp.workspace.move({ workspace = '$ws', monitor = 'HDMI-A-1' }))" 2>/dev/null || true
    done
    for ws in 0 2 4 6 8; do
        target_ws="$ws"
        [ "$ws" = "0" ] && target_ws="name:0"
        hyprctl eval "hl.dispatch(hl.dsp.workspace.move({ workspace = '$target_ws', monitor = 'DP-1' }))" 2>/dev/null || true
    done
    echo "extend" > "$STATE_FILE"
    command -v dunstify >/dev/null 2>&1 && dunstify -u normal -r 421178010 "Display Configuration" "Mode: Extended Displays"
    [ -x "$HOME/.config/eww/scripts/open-bars.sh" ] && "$HOME/.config/eww/scripts/open-bars.sh" &
}

set_mirror() {
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })' 2>/dev/null
    hyprctl eval 'hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "0x0", scale = 1, bitdepth = 8 })' 2>/dev/null
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1, bitdepth = 8, mirror = "DP-1" })' 2>/dev/null
    echo "mirror" > "$STATE_FILE"
    command -v dunstify >/dev/null 2>&1 && dunstify -u normal -r 421178010 "Display Configuration" "Mode: Mirrored Displays"
    [ -x "$HOME/.config/eww/scripts/open-bars.sh" ] && "$HOME/.config/eww/scripts/open-bars.sh" &
}

case "$1" in
    extend)
        set_extend
        ;;
    mirror)
        set_mirror
        ;;
    toggle)
        CURRENT=$(get_status)
        if [ "$CURRENT" = "extend" ]; then
            set_mirror
        else
            set_extend
        fi
        ;;
    status)
        get_status
        ;;
    *)
        echo "Usage: $0 {extend|mirror|toggle|status}"
        exit 1
        ;;
esac
