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
            # If control_center is open, dismiss it and catchers
            if eww active-windows 2>/dev/null | grep -q "^control_center:"; then
                eww close control_center control_center_catcher_dp control_center_catcher_hdmi control_center_catcher 2>/dev/null || true
                "$HOME/.config/eww/scripts/shutdown-action.sh" reset 2>/dev/null || true
            fi

            # If workspace_selector submap is active, reset it on focus change
            CURRENT_SUBMAP=$(hyprctl submap 2>/dev/null)
            if [ "$CURRENT_SUBMAP" = "workspace_selector" ]; then
                hyprctl eval 'hl.dispatch(hl.dsp.submap("reset"))' 2>/dev/null || true
            fi
            ;;
    esac
done
