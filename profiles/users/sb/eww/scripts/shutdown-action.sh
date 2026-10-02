#!/usr/bin/env bash

# Handles 2-step confirmation for shutdown in control_center overlay

STATE_FILE="$HOME/.cache/eww_shutdown_confirm"

case "$1" in
    click|"")
        CONFIRM=$(eww get shutdown_confirm 2>/dev/null)
        if [ "$CONFIRM" = "true" ]; then
            # Second click confirms shutdown
            rm -f "$STATE_FILE"
            eww update shutdown_confirm=false 2>/dev/null || true
            shutdown now || systemctl poweroff
        else
            # First click: activate confirmation state and auto-reset after 5 seconds
            eww update shutdown_confirm=true 2>/dev/null || true
            TIMER_ID=$(date +%s%N)
            echo "$TIMER_ID" > "$STATE_FILE"
            (
                sleep 5
                if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "$TIMER_ID" ]; then
                    eww update shutdown_confirm=false 2>/dev/null || true
                    rm -f "$STATE_FILE"
                fi
            ) &
        fi
        ;;
    reset)
        rm -f "$STATE_FILE"
        eww update shutdown_confirm=false 2>/dev/null || true
        ;;
esac
