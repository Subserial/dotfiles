#!/usr/bin/env bash

# Close active bar windows
eww close bar bar_dp bar_hdmi 2>/dev/null || true

# Check display mode
MODE=$("$HOME/.config/eww/scripts/display-select.sh" status 2>/dev/null)

if [ "$MODE" = "mirror" ]; then
    # In mirror mode, DP-1 is the source surface mirrored onto HDMI-A-1
    eww open bar_dp 2>/dev/null || eww open bar 2>/dev/null || true
else
    # Prefer HDMI-A-1 in extend mode
    ACTIVE_MONS=$(hyprctl monitors -j 2>/dev/null | jq -r '.[].name')
    if echo "$ACTIVE_MONS" | grep -q "^HDMI-A-1$"; then
        eww open bar_hdmi 2>/dev/null || eww open bar 2>/dev/null || true
    elif echo "$ACTIVE_MONS" | grep -q "^DP-1$"; then
        eww open bar_dp 2>/dev/null || eww open bar 2>/dev/null || true
    else
        eww open bar 2>/dev/null || true
    fi
fi
