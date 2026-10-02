#!/usr/bin/env bash

get_data() {
    local monitors_json=$(hyprctl monitors -j 2>/dev/null)

    local top_ws=$(echo "$monitors_json" | jq -r '([.[] | select(.name == "DP-1") | .activeWorkspace.name][0]) // ""')
    local bottom_ws=$(echo "$monitors_json" | jq -r '([.[] | select(.name == "HDMI-A-1") | .activeWorkspace.name][0]) // ""')

    if [ -z "$top_ws" ] || [ "$top_ws" = "null" ]; then
        top_ws=$(echo "$monitors_json" | jq -r 'sort_by(.y) | .[0].activeWorkspace.name // "0"')
    fi
    if [ -z "$bottom_ws" ] || [ "$bottom_ws" = "null" ]; then
        bottom_ws=$(echo "$monitors_json" | jq -r 'sort_by(.y) | .[1].activeWorkspace.name // .[0].activeWorkspace.name // "1"')
    fi

    local ws_display="${top_ws} | ${bottom_ws}"

    local submap=$(hyprctl submap 2>/dev/null)
    local is_selector="false"
    if [ "$submap" = "workspace_selector" ]; then
        is_selector="true"
    fi

    echo "{\"ws\":\"$ws_display\",\"top\":\"$top_ws\",\"bottom\":\"$bottom_ws\",\"submap\":$is_selector}"
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
