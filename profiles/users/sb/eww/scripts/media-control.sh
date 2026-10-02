#!/usr/bin/env bash

# media-control.sh
# Dispatches playerctl playback actions and seeking

ACTION="$1"
PARAM="${2:-}"

case "$ACTION" in
    play-pause)
        playerctl play-pause 2>/dev/null || true
        ;;
    next)
        playerctl next 2>/dev/null || true
        ;;
    previous)
        playerctl previous 2>/dev/null || true
        ;;
    seek)
        if [ -n "$PARAM" ]; then
            # PARAM is percentage (0-100)
            LEN_US=$(playerctl metadata --format "{{mpris:length}}" 2>/dev/null || echo "0")
            if [ -n "$LEN_US" ] && [ "$LEN_US" -gt 0 ] 2>/dev/null; then
                TARGET=$(awk -v l="$LEN_US" -v p="$PARAM" 'BEGIN { printf "%.2f", (l / 1000000) * (p / 100) }')
                playerctl position "$TARGET" 2>/dev/null || true
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {play-pause|next|previous|seek <pct>}"
        exit 1
        ;;
esac
