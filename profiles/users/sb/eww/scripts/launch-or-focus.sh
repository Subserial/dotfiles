#!/usr/bin/env bash

# Helper script for smart app launch/focus from Eww Control Center

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$1"

case "$APP" in
    discord)
        DISCORD_ADDR=$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.class | test("discord|WebCord"; "i")) | .address][0] // ""')
        if [ -n "$DISCORD_ADDR" ] && [ "$DISCORD_ADDR" != "null" ]; then
            hyprctl dispatch "hl.dsp.focus({ window = 'address:$DISCORD_ADDR' })" 2>/dev/null || true
        else
            discord-canary &
        fi
        ;;
    steam)
        STEAM_ADDR=$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.class == "steam" and (.title | test("Steam"; "i"))) | .address][0] // ""')
        if [ -z "$STEAM_ADDR" ] || [ "$STEAM_ADDR" = "null" ]; then
            STEAM_ADDR=$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.class == "steam") | .address][0] // ""')
        fi
        if [ -n "$STEAM_ADDR" ] && [ "$STEAM_ADDR" != "null" ]; then
            hyprctl dispatch "hl.dsp.focus({ window = 'address:$STEAM_ADDR' })" 2>/dev/null || true
        else
            steam &
        fi
        ;;
    files)
        thunar "$HOME" &
        ;;
    *)
        command -v "$APP" >/dev/null 2>&1 && "$APP" &
        ;;
esac

"$SCRIPT_DIR/popups.sh" close-all 2>/dev/null || true
