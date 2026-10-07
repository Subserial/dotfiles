#!/usr/bin/env bash

get_data() {
    local monitors_json
    monitors_json=$(hyprctl monitors -j 2>/dev/null)
    local top_ws="0" bottom_ws="1"

    if [ -n "$monitors_json" ] && [ "$monitors_json" != "[]" ]; then
        IFS=$'\t' read -r top_ws bottom_ws < <(echo "$monitors_json" | jq -r '
            (map(select(.name == "DP-1"))[0].activeWorkspace.name // "") as $dp |
            (map(select(.name == "HDMI-A-1"))[0].activeWorkspace.name // "") as $hdmi |
            (sort_by(.y)) as $sorted |
            (if $dp != "" and $dp != "null" then $dp else ($sorted[0].activeWorkspace.name // "0") end) as $top |
            (if $hdmi != "" and $hdmi != "null" then $hdmi else ($sorted[1].activeWorkspace.name // $sorted[0].activeWorkspace.name // "1") end) as $bot |
            "\($top)\t\($bot)"
        ' 2>/dev/null)
    fi

    local ws_display="${top_ws:-0} | ${bottom_ws:-1}"

    local submap
    submap=$(hyprctl submap 2>/dev/null)
    local is_selector="false"
    if [ "$submap" = "workspace_selector" ]; then
        is_selector="true"
    fi

    echo "{\"ws\":\"$ws_display\",\"top\":\"${top_ws:-0}\",\"bottom\":\"${bottom_ws:-1}\",\"submap\":$is_selector}"
}

# Print initial state
get_data

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

if [ -e "$SOCKET" ]; then
    nc -U "$SOCKET" 2>/dev/null | while read -r line; do
        case "$line" in
            "workspace>>"*|"focusedmon>>"*|"submap>>"*)
                get_data
                ;;
        esac
    done
else
    while true; do
        get_data
        sleep 1
    done
fi
