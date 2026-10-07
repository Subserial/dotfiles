#!/usr/bin/env bash

# Toggles workspace_selector submap

CURRENT_SUBMAP=$(hyprctl submap 2>/dev/null)

if [ "$CURRENT_SUBMAP" = "workspace_selector" ]; then
    hyprctl dispatch 'hl.dsp.submap("reset")' 2>/dev/null
else
    hyprctl dispatch 'hl.dsp.submap("workspace_selector")' 2>/dev/null
fi
