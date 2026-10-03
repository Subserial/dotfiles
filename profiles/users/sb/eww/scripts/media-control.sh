#!/usr/bin/env bash

# media-control.sh
# Dispatches playerctl playback actions and seeking

ACTION="$1"
ARG2="${2:-}"
ARG3="${3:-}"

# Parse player and parameter
PLAYER=""
PARAM=""

if [ "$ACTION" = "seek" ]; then
    if [[ "$ARG2" =~ ^[0-9]+$ ]]; then
        PARAM="$ARG2"
        PLAYER="$ARG3"
    else
        PLAYER="$ARG2"
        PARAM="$ARG3"
    fi
else
    PLAYER="$ARG2"
    PARAM="$ARG3"
fi

PLAYER_FLAG=()
if [ -n "$PLAYER" ]; then
    PLAYER_FLAG=(-p "$PLAYER")
fi

case "$ACTION" in
    play-pause)
        playerctl "${PLAYER_FLAG[@]}" play-pause 2>/dev/null || true
        ;;
    next)
        playerctl "${PLAYER_FLAG[@]}" next 2>/dev/null || true
        ;;
    previous)
        playerctl "${PLAYER_FLAG[@]}" previous 2>/dev/null || true
        ;;
    seek)
        if [ -n "$PARAM" ]; then
            LEN_US=$(playerctl "${PLAYER_FLAG[@]}" metadata --format "{{mpris:length}}" 2>/dev/null || echo "0")
            if [ -n "$LEN_US" ] && [ "$LEN_US" -gt 0 ] 2>/dev/null; then
                TARGET=$(awk -v l="$LEN_US" -v p="$PARAM" 'BEGIN { if (p > 100) p = 100; if (p < 0) p = 0; printf "%.2f", (l / 1000000) * (p / 100) }')
                playerctl "${PLAYER_FLAG[@]}" position "$TARGET" 2>/dev/null || true
            fi
        fi
        ;;
    *)
        echo "Usage: $0 {play-pause|next|previous|seek} [player] [param]"
        exit 1
        ;;
esac
