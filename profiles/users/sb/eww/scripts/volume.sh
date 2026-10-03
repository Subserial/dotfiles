#!/usr/bin/env bash

get_vol() {
    vol_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [[ "$vol_output" == *"[MUTED]"* ]]; then
        echo "0"
    else
        val=$(echo "$vol_output" | awk '{print $2}')
        awk -v v="$val" 'BEGIN { printf "%.0f\n", (v ? v : 0) * 100 }'
    fi
}

get_icon() {
    vol_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [[ "$vol_output" == *"[MUTED]"* ]]; then
        echo "🔇"
    else
        val=$(echo "$vol_output" | awk '{print $2}')
        pct=$(awk -v v="$val" 'BEGIN { printf "%.0f\n", (v ? v : 0) * 100 }')
        if [ "$pct" -ge 65 ]; then
            echo "🔊"
        elif [ "$pct" -ge 30 ]; then
            echo "🔉"
        elif [ "$pct" -gt 0 ]; then
            echo "🔈"
        else
            echo "🔇"
        fi
    fi
}

case "$1" in
    get)
        get_vol
        ;;
    icon)
        get_icon
        ;;
    set)
        val="$2"
        if [ -n "$val" ]; then
            target=$(awk -v v="$val" 'BEGIN { printf "%.2f", (v > 100 ? 100 : (v < 0 ? 0 : v)) / 100 }')
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$target"
            if command -v eww >/dev/null 2>&1; then
                new_vol=$(awk -v v="$val" 'BEGIN { printf "%.0f", (v > 100 ? 100 : (v < 0 ? 0 : v)) }')
                eww update volume_val="$new_vol" 2>/dev/null || true
            fi
        fi
        ;;
    step)
        delta="$2"
        if [ -n "$delta" ]; then
            clean_delta="${delta%\%}"
            if [[ "$clean_delta" =~ ^\+ ]]; then
                wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${clean_delta#+}%+"
            elif [[ "$clean_delta" =~ ^\- ]]; then
                wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${clean_delta#-}%-"
            else
                wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${clean_delta}%+"
            fi
            if command -v eww >/dev/null 2>&1; then
                new_vol=$(get_vol)
                new_icon=$(get_icon)
                eww update volume_val="$new_vol" volume_icon="$new_icon" 2>/dev/null || true
            fi
        fi
        ;;
    up)
        "$0" step "+5%"
        ;;
    down)
        "$0" step "-5%"
        ;;
    toggle-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if command -v eww >/dev/null 2>&1; then
            new_vol=$(get_vol)
            new_icon=$(get_icon)
            eww update volume_val="$new_vol" volume_icon="$new_icon" 2>/dev/null || true
        fi
        ;;
    *)
        get_vol
        ;;
esac
