#!/usr/bin/env bash

# media-info.sh
# Streams JSON metadata and playback progress for Eww

CACHE_DIR="$HOME/.cache/eww/art"
mkdir -p "$CACHE_DIR"

FMT='{"status":"{{status}}","title":"{{markup_escape(title)}}","artist":"{{markup_escape(artist)}}","album":"{{markup_escape(album)}}","art":"{{mpris:artUrl}}","length":"{{mpris:length}}"}'

get_media_json() {
    if ! command -v playerctl >/dev/null 2>&1; then
        echo '{"available":false}'
        return
    fi

    local meta pos
    meta=$(playerctl metadata --format "$FMT" 2>/dev/null)
    if [ -z "$meta" ]; then
        echo '{"available":false}'
        return
    fi

    pos=$(playerctl position 2>/dev/null || echo "0")

    # Download remote art if needed, or strip file://
    local art_url art_path
    art_url=$(echo "$meta" | jq -r '.art // ""')
    if [[ "$art_url" == file://* ]]; then
        art_path="${art_url#file://}"
    elif [[ "$art_url" =~ ^https?:// ]]; then
        local url_hash
        url_hash=$(echo -n "$art_url" | md5sum | cut -d' ' -f1)
        art_path="$CACHE_DIR/${url_hash}.png"
        if [ ! -f "$art_path" ]; then
            curl -sSL "$art_url" -o "$art_path" 2>/dev/null &
        fi
    else
        art_path="$art_url"
    fi

    echo "$meta" | jq --arg pos "$pos" --arg art "$art_path" '
      if . == null or . == "" then
        {"available": false}
      else
        . + {
          "available": true,
          "position": ($pos | tonumber? // 0 | floor),
          "length": ((.length | tonumber? // 0) / 1000000 | floor),
          "art": $art
        } |
        . + {
          "position_pct": (if .length > 0 then ((.position / .length) * 100 | floor) else 0 end),
          "position_str": (
            (.position % 3600 / 60 | floor | tostring | if length == 1 then "0" + . else . end) + ":" +
            (.position % 60 | floor | tostring | if length == 1 then "0" + . else . end)
          ),
          "length_str": (
            (.length % 3600 / 60 | floor | tostring | if length == 1 then "0" + . else . end) + ":" +
            (.length % 60 | floor | tostring | if length == 1 then "0" + . else . end)
          )
        }
      end
    ' -c 2>/dev/null || echo '{"available":false}'
}

# Initial state
get_media_json

# Reactive update loop
while true; do
    get_media_json
    sleep 1
done
