#!/usr/bin/env bash

# Background watcher for Hyprland events:
# 1. Closes control_center overlay when another window gains focus
# 2. Cancels workspace_selector submap when focus changes

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [ ! -e "$SOCKET" ]; then
    exit 0
fi

nc -U "$SOCKET" 2>/dev/null | while read -r line; do
    case "$line" in
        "activewindow>>"*|"workspace>>"*|"focusedmon>>"*)
            # If any popup is open, dismiss it
            if eww active-windows 2>/dev/null | grep -qE "^(control_center|media_player|media_player_tiled|popups_tray):"; then
                "$HOME/.config/eww/scripts/popups.sh" close-all 2>/dev/null || true
            fi

            # If workspace_selector submap is active, reset it on focus change
            CURRENT_SUBMAP=$(hyprctl submap 2>/dev/null)
            if [ "$CURRENT_SUBMAP" = "workspace_selector" ]; then
                hyprctl dispatch 'hl.dsp.submap("reset")' 2>/dev/null || true
            fi
            ;;
    esac
done
