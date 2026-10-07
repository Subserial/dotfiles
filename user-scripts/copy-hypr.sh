#!/usr/bin/env bash
set -euo pipefail

# Copies Hyprland user configuration from the repository profiles into the target user config directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Usage: $(basename "$0") <user> [destination_dir]"
    echo ""
    echo "Arguments:"
    echo "  <user>             User profile name in profiles/users/ (e.g. 'sb', 'twilight')"
    echo "  [destination_dir]  Target Hyprland config directory (default: ~/.config/hypr)"
    echo ""
    echo "Example:"
    echo "  $(basename "$0") sb ~/.config/hypr"
    exit 1
}

if [ "$#" -lt 1 ]; then
    usage
fi

USER_NAME="$1"
DEST_DIR="${2:-$HOME/.config/hypr}"
USER_PROFILE_DIR="$REPO_ROOT/profiles/users/$USER_NAME"

if [ ! -d "$USER_PROFILE_DIR" ]; then
    echo "Error: User profile '$USER_NAME' not found in $REPO_ROOT/profiles/users/" >&2
    echo "Available user profiles:" >&2
    for dir in "$REPO_ROOT/profiles/users"/*; do
        if [ -d "$dir" ]; then
            echo "  - $(basename "$dir")" >&2
        fi
    done
    exit 1
fi

mkdir -p "$DEST_DIR"

# hyprland.user.lua
if [ -f "$USER_PROFILE_DIR/hyprland.user.lua" ]; then
    target_file="$DEST_DIR/hyprland.user.lua"
    if [ -f "$target_file" ]; then
        backup_file="$target_file.bak"
        echo "Creating backup of existing config -> $backup_file"
        cp "$target_file" "$backup_file"
    fi
    echo "Copying $USER_PROFILE_DIR/hyprland.user.lua -> $target_file"
    cp "$USER_PROFILE_DIR/hyprland.user.lua" "$target_file"
    chmod u+w "$target_file"
    echo ""
    echo "Successfully updated Hyprland configuration in $DEST_DIR"
    echo "To reload Hyprland session immediately: hyprctl reload"
    exit 0
fi

echo "Warning: No Hyprland configuration files found in $USER_PROFILE_DIR to copy." >&2
exit 1
