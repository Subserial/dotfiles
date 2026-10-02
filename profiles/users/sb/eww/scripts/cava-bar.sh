#!/usr/bin/env bash

# cava-bar.sh
# Streams PipeWire audio visualization as ASCII bars for Eww

if ! command -v cava >/dev/null 2>&1; then
    echo "        "
    exit 0
fi

CAVA_CONF="/tmp/cava_eww_$UID.conf"

cat << EOF > "$CAVA_CONF"
[general]
bars = 8
framerate = 25

[input]
method = pulse

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 59
EOF

while true; do
    cava -p "$CAVA_CONF" 2>/dev/null | sed -u "y/01234567/ ▂▃▄▅▆▇█/; s/;//g"
    sleep 1
done
