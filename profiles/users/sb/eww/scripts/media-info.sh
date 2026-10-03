#!/usr/bin/env bash

# media-info.sh
# Streams JSON metadata and playback progress for all active MPRIS players

CACHE_DIR="$HOME/.cache/eww/art"
mkdir -p "$CACHE_DIR"
DEFAULT_ART="$CACHE_DIR/default.png"
if [ ! -f "$DEFAULT_ART" ]; then
    ffmpeg -y -f lavfi -i color=c=black@0.0:s=1x1 -frames:v 1 "$DEFAULT_ART" 2>/dev/null || touch "$DEFAULT_ART"
fi

FMT='{"name":"{{playerName}}","status":"{{status}}","title":"{{markup_escape(title)}}","artist":"{{markup_escape(artist)}}","album":"{{markup_escape(album)}}","art":"{{mpris:artUrl}}","length":"{{mpris:length}}","url":"{{xesam:url}}"}'

get_media_json() {
    if ! command -v playerctl >/dev/null 2>&1; then
        echo "{\"available\":false,\"art\":\"$DEFAULT_ART\",\"players\":[]}"
        return
    fi

    local player_names
    player_names=$(playerctl -l 2>/dev/null)
    if [ -z "$player_names" ]; then
        echo "{\"available\":false,\"art\":\"$DEFAULT_ART\",\"players\":[]}"
        return
    fi

    # Identify default active player from playerctl (most recently active)
    local default_player
    default_player=$(playerctl status -f '{{playerName}}' 2>/dev/null | head -n 1 || echo "")

    local items=()

    while IFS= read -r p; do
        [ -z "$p" ] && continue

        local meta pos
        meta=$(playerctl -p "$p" metadata --format "$FMT" 2>/dev/null)
        [ -z "$meta" ] && continue

        local title art_url source_url status
        IFS=$'\t' read -r title art_url source_url status < <(echo "$meta" | jq -r '[.title // "", .art // "", .url // "", .status // ""] | @tsv' 2>/dev/null)
        [ -z "$title" ] && continue

        pos=$(playerctl -p "$p" position 2>/dev/null || echo "0")

        # Resolve artwork
        local art_path
        if [[ "$art_url" == file://* ]]; then
            art_path="${art_url#file://}"
        elif [[ "$art_url" =~ ^https?:// ]]; then
            local url_hash
            url_hash=$(echo -n "$art_url" | md5sum | cut -d' ' -f1)
            art_path="$CACHE_DIR/${url_hash}.png"
            local failed_marker="$CACHE_DIR/${url_hash}.failed"
            local dl_marker="$CACHE_DIR/${url_hash}.downloading"
            if [ ! -f "$art_path" ] && [ ! -f "$failed_marker" ] && [ ! -f "$dl_marker" ]; then
                touch "$dl_marker"
                (
                    if curl -sSL --connect-timeout 2 --max-time 4 "$art_url" -o "${art_path}.tmp" 2>/dev/null && [ -s "${art_path}.tmp" ]; then
                        mv -f "${art_path}.tmp" "$art_path"
                    else
                        rm -f "${art_path}.tmp"
                        touch "$failed_marker"
                    fi
                    rm -f "$dl_marker"
                ) &
            fi
        else
            art_path="$art_url"
        fi

        if [ -z "$art_path" ] || [ ! -f "$art_path" ]; then
            art_path="$DEFAULT_ART"
        fi

        # Source badge detection
        local source_name
        if [[ "$source_url" == *youtube.com* || "$source_url" == *youtu.be* ]]; then
            source_name="YouTube"
        elif [[ "$source_url" == *deezer.com* ]]; then
            source_name="Deezer"
        elif [[ "$source_url" == *soundcloud.com* ]]; then
            source_name="SoundCloud"
        elif [[ "$p" == *spotify* ]]; then
            source_name="Spotify"
        elif [[ "$p" == *deezer* ]]; then
            source_name="Deezer"
        elif [[ "$p" == *firefox* ]]; then
            source_name="Firefox"
        elif [[ "$p" == *chromium* || "$p" == *chrome* ]]; then
            source_name="Browser"
        elif [[ "$p" == *vlc* ]]; then
            source_name="VLC"
        elif [[ "$p" == *mpv* ]]; then
            source_name="MPV"
        else
            source_name="${p%%.*}"
        fi

        # Prominence score:
        # Playing = 100, Paused = 50, Stopped = 10
        # If default player = +200
        local score=10
        if [ "$status" = "Playing" ]; then
            score=100
        elif [ "$status" = "Paused" ]; then
            score=50
        fi
        if [ -n "$default_player" ] && [[ "$p" == "$default_player"* ]]; then
            score=$((score + 200))
        fi

        local item_json
        item_json=$(echo "$meta" | jq \
          --arg p "$p" \
          --arg pos "$pos" \
          --arg art "$art_path" \
          --arg src "$source_name" \
          --argjson score "$score" '
          . + {
            "name": $p,
            "source": $src,
            "art": $art,
            "score": $score,
            "position": ($pos | tonumber? // 0 | floor),
            "length": ((.length | tonumber? // 0) / 1000000 | floor)
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
        ' -c 2>/dev/null)

        if [ -n "$item_json" ]; then
            items+=("$item_json")
        fi
    done <<< "$player_names"

    if [ ${#items[@]} -eq 0 ]; then
        echo "{\"available\":false,\"art\":\"$DEFAULT_ART\",\"players\":[]}"
        return
    fi

    # Assemble JSON array and sort by score ascending
    # (Least prominent at top / index 0, MOST PROMINENT AT BOTTOM / index -1)
    local raw_array
    raw_array=$(printf '%s\n' "${items[@]}" | jq -s 'sort_by(.score)')

    # Top-level fields take the most prominent player (last element)
    echo "$raw_array" | jq -c '
      (.[-1]) as $prominent |
      {
        "available": true,
        "title": $prominent.title,
        "artist": $prominent.artist,
        "album": $prominent.album,
        "art": $prominent.art,
        "status": $prominent.status,
        "source": $prominent.source,
        "players": .
      }
    ' 2>/dev/null || echo "{\"available\":false,\"art\":\"$DEFAULT_ART\",\"players\":[]}"
}

# Initial output
get_media_json

# Loop every second
while true; do
    get_media_json
    sleep 1
done
