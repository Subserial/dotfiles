#!/usr/bin/env bash

# Print initial active workspace
hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 1' 2>/dev/null || echo "1"

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [ -e "$SOCKET" ]; then
    nc -U "$SOCKET" 2>/dev/null | while read -r line; do
        case "$line" in
            workspace>>*|focusedmon>>*)
                hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 1' 2>/dev/null || echo "1"
                ;;
        esac
    done
else
    while true; do
        hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 1' 2>/dev/null || echo "1"
        sleep 1
    done
fi
