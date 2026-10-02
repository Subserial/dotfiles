#!/usr/bin/env bash

# popups.sh
# Manages the unified horizontal popups tray and backdrop catchers

ACTION="${1:-close-all}"
LAST_MON_FILE="$HOME/.cache/eww_popups_mon"

get_active_mon() {
    local mon
    mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name')
    echo "${mon:-0}"
}

ensure_tray_open() {
    local target_mon="$1"
    local active_mons
    active_mons=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name')

    local last_mon
    last_mon=$(cat "$LAST_MON_FILE" 2>/dev/null || echo "")
    if [ -n "$last_mon" ] && [ "$last_mon" != "$target_mon" ]; then
        eww close popups_tray 2>/dev/null || true
    fi

    if echo "$active_mons" | grep -q "^DP-1$"; then
        eww open control_center_catcher_dp 2>/dev/null || true
    fi
    if echo "$active_mons" | grep -q "^HDMI-A-1$"; then
        eww open control_center_catcher_hdmi 2>/dev/null || true
    fi
    eww open control_center_catcher 2>/dev/null || true

    eww open popups_tray --screen "$target_mon" 2>/dev/null || true
    echo "$target_mon" > "$LAST_MON_FILE"
}

close_all() {
    eww update control_center_open=false 2>/dev/null || true
    eww update media_player_open=false 2>/dev/null || true
    eww close popups_tray control_center_catcher_dp control_center_catcher_hdmi control_center_catcher 2>/dev/null || true
    rm -f "$LAST_MON_FILE"
    "$HOME/.config/eww/scripts/shutdown-action.sh" reset 2>/dev/null || true
}

case "$ACTION" in
    toggle-control-center)
        ACTIVE_MON=$(get_active_mon)
        CC_STATE=$(eww get control_center_open 2>/dev/null || echo "false")
        LAST_MON=$(cat "$LAST_MON_FILE" 2>/dev/null || echo "")

        if [ "$CC_STATE" = "true" ] && [ "$LAST_MON" = "$ACTIVE_MON" ]; then
            eww update control_center_open=false 2>/dev/null || true
            MEDIA_STATE=$(eww get media_player_open 2>/dev/null || echo "false")
            if [ "$MEDIA_STATE" = "false" ]; then
                close_all
            fi
        else
            ensure_tray_open "$ACTIVE_MON"
            eww update control_center_open=true 2>/dev/null || true
        fi
        ;;

    toggle-media)
        ACTIVE_MON=$(get_active_mon)
        MEDIA_STATE=$(eww get media_player_open 2>/dev/null || echo "false")
        LAST_MON=$(cat "$LAST_MON_FILE" 2>/dev/null || echo "")

        if [ "$MEDIA_STATE" = "true" ] && [ "$LAST_MON" = "$ACTIVE_MON" ]; then
            eww update media_player_open=false 2>/dev/null || true
            CC_STATE=$(eww get control_center_open 2>/dev/null || echo "false")
            if [ "$CC_STATE" = "false" ]; then
                close_all
            fi
        else
            ensure_tray_open "$ACTIVE_MON"
            eww update media_player_open=true 2>/dev/null || true
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
