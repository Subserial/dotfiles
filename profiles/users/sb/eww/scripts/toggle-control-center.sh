#!/usr/bin/env bash

# toggle-control-center.sh
# Backward-compatibility wrapper pointing to popups.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$1" in
    close)
        "$DIR/popups.sh" close-all
        ;;
    open)
        "$DIR/popups.sh" toggle-control-center
        ;;
    *)
        "$DIR/popups.sh" toggle-control-center
        ;;
esac
