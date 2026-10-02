#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/eww_display_mode"

get_status() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        # Inspect hyprctl monitors
        if hyprctl monitors -j 2>/dev/null | grep -q '"mirrorOf": *"DP-1"'; then
            echo "mirror"
        else
            echo "extend"
        fi
    fi
}

set_extend() {
    hyprctl keyword monitor "eDP-1, disable"
    hyprctl keyword monitor "DP-1, 1920x1080@60, 0x0, 1"
    hyprctl keyword monitor "HDMI-A-1, 1920x1080@75, 0x1080, 1"
    echo "extend" > "$STATE_FILE"
    command -v dunstify >/dev/null 2>&1 && dunstify -u normal -r 421178010 "Display Configuration" "Mode: Extended Displays"
}

set_mirror() {
    hyprctl keyword monitor "eDP-1, disable"
    hyprctl keyword monitor "DP-1, 1920x1080@60, 0x0, 1"
    hyprctl keyword monitor "HDMI-A-1, 1920x1080@60, 0x0, 1, mirror, DP-1"
    echo "mirror" > "$STATE_FILE"
    command -v dunstify >/dev/null 2>&1 && dunstify -u normal -r 421178010 "Display Configuration" "Mode: Mirrored Displays"
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
