#!/usr/bin/env bash
set -euo pipefail

# Copies eww user configuration from the repository profiles into the target user config directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    echo "Usage: $(basename "$0") <user> [destination_dir]"
    echo ""
    echo "Arguments:"
    echo "  <user>             User profile name in profiles/users/ (e.g. 'sb', 'twilight')"
    echo "  [destination_dir]  Target Hyprland config directory (default: ~/.config/eww)"
    echo ""
    echo "Example:"
    echo "  $(basename "$0") sb ~/.config/eww"
    exit 1
}

if [ "$#" -lt 1 ]; then
    usage
fi

USER_NAME="$1"
DEST_DIR="${2:-$HOME/.config/eww}"
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

for file in eww.scss eww.yuck; do
	source_file="$USER_PROFILE_DIR/eww/$file"
	if [ -f "$source_file" ]; then
		target_file="$DEST_DIR/$file"
		if [ -f "$target_file" ]; then
			backup_file="$target_file.bak"
      echo "Creating backup of existing config -> $backup_file"
      cp "$target_file" "$backup_file"
    fi
    echo "Copying $source_file -> $target_file"
    cp "$source_file" "$target_file"
    chmod u+w "$target_file"
  fi
done

# scripts folder
scripts_source="$USER_PROFILE_DIR/eww/scripts"
scripts_dest="$DEST_DIR/scripts"

if [ -d "$scripts_source" ]; then
  mkdir -p "$scripts_dest"
  for source_file in "$scripts_source"/*; do
    target_file="$scripts_dest/$(basename "$source_file")"
    if [ -f "$target_file" ]; then
      backup_file="$target_file.bak"
      echo "Creating backup of existing config -> $backup_file"
      cp "$target_file" "$backup_file"
    fi
    echo "Copying $source_file -> $target_file"
    cp "$source_file" "$target_file"
    chmod u+w "$target_file"
  done
fi

echo "Successfully updated eww configuration in $DEST_DIR"
