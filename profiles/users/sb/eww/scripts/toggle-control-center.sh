#!/usr/bin/env bash

ACTIVE_MON=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name')
if [ -z "$ACTIVE_MON" ]; then
    ACTIVE_MON="0"
fi

LAST_MON_FILE="$HOME/.cache/eww_control_center_mon"
IS_OPEN=$(eww active-windows 2>/dev/null | grep -E "^control_center:")

close_overlay() {
    eww close control_center control_center_catcher_dp control_center_catcher_hdmi control_center_catcher 2>/dev/null || true
    rm -f "$LAST_MON_FILE"
    "$HOME/.config/eww/scripts/shutdown-action.sh" reset 2>/dev/null || true
}

open_overlay() {
    local target_mon="$1"
    local active_mons=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name')
    if echo "$active_mons" | grep -q "^DP-1$"; then
        eww open control_center_catcher_dp 2>/dev/null || true
    fi
    if echo "$active_mons" | grep -q "^HDMI-A-1$"; then
        eww open control_center_catcher_hdmi 2>/dev/null || true
    fi
    eww open control_center_catcher 2>/dev/null || true

    eww open control_center --screen "$target_mon"
    echo "$target_mon" > "$LAST_MON_FILE"
    "$HOME/.config/eww/scripts/shutdown-action.sh" reset 2>/dev/null || true
}

case "$1" in
    close)
        close_overlay
        ;;
    open)
        open_overlay "$ACTIVE_MON"
        ;;
    *)
        if [ -n "$IS_OPEN" ]; then
            LAST_MON=$(cat "$LAST_MON_FILE" 2>/dev/null)
            if [ "$LAST_MON" = "$ACTIVE_MON" ]; then
                close_overlay
            else
                close_overlay
                open_overlay "$ACTIVE_MON"
            fi
        else
            open_overlay "$ACTIVE_MON"
        fi
        ;;
esac
