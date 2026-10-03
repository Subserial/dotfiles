#!/usr/bin/env bash

# popups.sh
# Manages pop-up flex tray and backdrop catchers

ACTION="${1:-close-all}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAST_MON_FILE="$HOME/.cache/eww_popups_mon"

get_active_mon() {
    local pos
    pos=$(hyprctl cursorpos -j 2>/dev/null)
    if [ -n "$pos" ]; then
        local cx cy
        cx=$(echo "$pos" | jq '.x // 0' 2>/dev/null)
        cy=$(echo "$pos" | jq '.y // 0' 2>/dev/null)
        if [ -n "$cx" ] && [ -n "$cy" ]; then
            local cursor_mon
            cursor_mon=$(hyprctl monitors -j 2>/dev/null | jq -r --argjson cx "$cx" --argjson cy "$cy" '
              .[] | select($cx >= .x and $cx < (.x + .width) and $cy >= .y and $cy < (.y + .height)) | .name
            ' 2>/dev/null | head -n 1)
            if [ -n "$cursor_mon" ] && [ "$cursor_mon" != "null" ]; then
                echo "$cursor_mon"
                return
            fi
        fi
    fi

    local mon
    mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .name')
    echo "${mon:-HDMI-A-1}"
}

is_tray_open() {
    eww active-windows 2>/dev/null | grep -q "^popups_tray:"
}

open_catchers() {
    local active_mons
    active_mons=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo "")

    local catchers=()
    if echo "$active_mons" | grep -q "^DP-1$"; then
        catchers+=(control_center_catcher_dp)
    fi
    if echo "$active_mons" | grep -q "^HDMI-A-1$"; then
        catchers+=(control_center_catcher_hdmi)
    fi
    if [ ${#catchers[@]} -eq 0 ]; then
        catchers+=(control_center_catcher)
    fi
    eww open-many "${catchers[@]}" 2>/dev/null || true
}

close_all() {
    eww update control_center_open=false media_player_open=false 2>/dev/null || true
    eww close popups_tray control_center_catcher_dp control_center_catcher_hdmi control_center_catcher 2>/dev/null || true
    rm -f "$LAST_MON_FILE"
    "$SCRIPT_DIR/shutdown-action.sh" reset 2>/dev/null || true
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
            if ! is_tray_open || [ "$LAST_MON" != "$ACTIVE_MON" ]; then
                open_catchers
                eww update control_center_open=true
                eww open popups_tray --screen "$ACTIVE_MON" 2>/dev/null || true
            else
                eww update control_center_open=true
            fi
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
            if ! is_tray_open || [ "$LAST_MON" != "$ACTIVE_MON" ]; then
                open_catchers
                eww update media_player_open=true
                eww open popups_tray --screen "$ACTIVE_MON" 2>/dev/null || true
            else
                eww update media_player_open=true
            fi
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
