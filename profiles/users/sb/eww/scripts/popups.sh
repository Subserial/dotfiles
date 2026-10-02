#!/usr/bin/env bash

# popups.sh
# Manages pop-up flex tray and backdrop catchers

ACTION="${1:-close-all}"
LAST_MON_FILE="$HOME/.cache/eww_popups_mon"

get_active_mon() {
    local mon
    mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name')
    echo "${mon:-0}"
}

is_tray_open() {
    eww active-windows 2>/dev/null | grep -q "^popups_tray:"
}

open_catchers() {
    local active_mons
    active_mons=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo "")

    local opened=false
    if echo "$active_mons" | grep -q "^DP-1$"; then
        eww open control_center_catcher_dp 2>/dev/null || true
        opened=true
    fi
    if echo "$active_mons" | grep -q "^HDMI-A-1$"; then
        eww open control_center_catcher_hdmi 2>/dev/null || true
        opened=true
    fi
    if [ "$opened" = false ]; then
        eww open control_center_catcher 2>/dev/null || true
    fi
}

close_all() {
    eww update control_center_open=false media_player_open=false 2>/dev/null || true
    eww close popups_tray control_center media_player media_player_tiled control_center_catcher_dp control_center_catcher_hdmi control_center_catcher 2>/dev/null || true
    rm -f "$LAST_MON_FILE"
    "$HOME/.config/eww/scripts/shutdown-action.sh" reset 2>/dev/null || true
}

case "$ACTION" in
    toggle-control-center)
        ACTIVE_MON=$(get_active_mon)
        LAST_MON=$(cat "$LAST_MON_FILE" 2>/dev/null || echo "")
        IS_CTRL=$(eww get control_center_open 2>/dev/null || echo "false")
        IS_MEDIA=$(eww get media_player_open 2>/dev/null || echo "false")

        # If monitor changed while tray is open, reopen on new monitor
        if is_tray_open && [ -n "$LAST_MON" ] && [ "$LAST_MON" != "$ACTIVE_MON" ]; then
            eww close popups_tray 2>/dev/null || true
        fi

        if is_tray_open && [ "$IS_CTRL" = "true" ] && [ "$LAST_MON" = "$ACTIVE_MON" ]; then
            eww update control_center_open=false
            if [ "$IS_MEDIA" != "true" ]; then
                close_all
            fi
        else
            open_catchers
            if ! is_tray_open || [ "$LAST_MON" != "$ACTIVE_MON" ]; then
                eww open popups_tray --screen "$ACTIVE_MON" 2>/dev/null || true
            fi
            eww update control_center_open=true
            echo "$ACTIVE_MON" > "$LAST_MON_FILE"
        fi
        ;;

    toggle-media)
        ACTIVE_MON=$(get_active_mon)
        LAST_MON=$(cat "$LAST_MON_FILE" 2>/dev/null || echo "")
        IS_CTRL=$(eww get control_center_open 2>/dev/null || echo "false")
        IS_MEDIA=$(eww get media_player_open 2>/dev/null || echo "false")

        # If monitor changed while tray is open, reopen on new monitor
        if is_tray_open && [ -n "$LAST_MON" ] && [ "$LAST_MON" != "$ACTIVE_MON" ]; then
            eww close popups_tray 2>/dev/null || true
        fi

        if is_tray_open && [ "$IS_MEDIA" = "true" ] && [ "$LAST_MON" = "$ACTIVE_MON" ]; then
            eww update media_player_open=false
            if [ "$IS_CTRL" != "true" ]; then
                close_all
            fi
        else
            open_catchers
            if ! is_tray_open || [ "$LAST_MON" != "$ACTIVE_MON" ]; then
                eww open popups_tray --screen "$ACTIVE_MON" 2>/dev/null || true
            fi
            eww update media_player_open=true
            echo "$ACTIVE_MON" > "$LAST_MON_FILE"
        fi
        ;;

    close-all|close)
        close_all
        ;;

    *)
        echo "Usage: $0 {toggle-control-center|toggle-media|close-all}"
        exit 1
        ;;
esac
