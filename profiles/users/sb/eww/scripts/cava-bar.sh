#!/usr/bin/env bash

# cava-bar.sh
# Streams PipeWire audio visualization as ASCII bars for Eww

if ! command -v cava >/dev/null 2>&1; then
    echo "▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAVA_CONF="$SCRIPT_DIR/cava.conf"

while true; do
    cava -p "$CAVA_CONF" 2>/dev/null | sed -u "y/01234567/▁▂▃▄▅▆▇█/; s/;//g"
    sleep 1
done
