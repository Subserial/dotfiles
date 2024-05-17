#!/usr/bin/env sh
wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
dunstify -u normal -r 421178001 "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
