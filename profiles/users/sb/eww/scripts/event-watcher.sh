#!/usr/bin/env bash

# Background watcher for Hyprland events:
# 1. Closes control_center overlay when another window gains focus
# 2. Cancels workspace_selector submap when focus changes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/eww_event_watcher.pid"

if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        exit 0
    fi
fi
echo "$$" > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT INT TERM

while true; do
    SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    if [ -e "$SOCKET" ]; then
        nc -U "$SOCKET" 2>/dev/null | while read -r line; do
            case "$line" in
                "activewindow>>"*|"activewindowv2>>"*|"workspace>>"*|"workspacev2>>"*)
                    # If popup tray is open, dismiss it on window focus or workspace change
                    if eww active-windows 2>/dev/null | grep -q "^popups_tray:"; then
                        "$SCRIPT_DIR/popups.sh" close-all 2>/dev/null &
                    fi

                    # If workspace_selector submap is active, reset it on focus change
                    CURRENT_SUBMAP=$(hyprctl submap 2>/dev/null)
                    if [ "$CURRENT_SUBMAP" = "workspace_selector" ]; then
                        hyprctl dispatch 'hl.dsp.submap("reset")' 2>/dev/null || true
                    fi
                    ;;
            esac
        done
    fi
    sleep 1
done
