#!/usr/bin/env bash

# Screen brightness helper script for Eww using hyprsunset gamma

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/hyprsunset_gamma"

get_brightness() {
    if [ -f "$STATE_FILE" ]; then
        local val
        val=$(cat "$STATE_FILE" 2>/dev/null)
        if [[ "$val" =~ ^[0-9]+$ ]] && [ "$val" -ge 1 ] && [ "$val" -le 100 ]; then
            echo "$val"
            return
        fi
    fi

    # Fallback to brightnessctl if available and active
    if command -v brightnessctl >/dev/null 2>&1; then
        local max cur
        max=$(brightnessctl m 2>/dev/null)
        cur=$(brightnessctl g 2>/dev/null)
        if [ -n "$max" ] && [ "$max" -gt 0 ] 2>/dev/null; then
            echo $(( cur * 100 / max ))
            return
        fi
    fi

    echo "100"
}

set_brightness() {
    local raw="$1"
    [ -z "$raw" ] && return

    # Round to integer and clamp between 10 and 100
    local target
    target=$(awk -v v="$raw" 'BEGIN {
        r = int(v + 0.5);
        if (r > 100) r = 100;
        if (r < 10) r = 10;
        print r;
    }')

    [ -z "$target" ] && return

    mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null
    echo "$target" > "$STATE_FILE"

    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl hyprsunset gamma "$target" >/dev/null 2>&1 || true
    fi

    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl s "${target}%" 2>/dev/null || true
    fi
}

step_brightness() {
    local delta="$1"
    local cur
    cur=$(get_brightness)
    local target=$(( cur + delta ))
    if [ "$target" -gt 100 ]; then
        target=100
    elif [ "$target" -lt 10 ]; then
        target=10
    fi

    mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null
    echo "$target" > "$STATE_FILE"

    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl hyprsunset gamma "$target" >/dev/null 2>&1 || true
    fi

    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl s "${target}%" 2>/dev/null || true
    fi

    if command -v eww >/dev/null 2>&1; then
        eww update brightness_val="$target" >/dev/null 2>&1 || true
    fi
}

case "$1" in
    get)
        get_brightness
        ;;
    set)
        set_brightness "$2"
        ;;
    step)
        step_brightness "$2"
        ;;
    +*|-*)
        step_brightness "$1"
        ;;
    *)
        get_brightness
        ;;
esac
