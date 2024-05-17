#!/usr/bin/env sh

# Set device to be toggled
HYPRLAND_DEVICE_1="pixa3854:00-093a:0274-touchpad"
HYPRLAND_VARIABLE_1="device:$HYPRLAND_DEVICE_1:enabled"
HYPRLAND_DEVICE_2="pixa3854:00-093a:0274-mouse"
HYPRLAND_VARIABLE_2="device:$HYPRLAND_DEVICE_2:enabled"

if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

# Check if device is currently enabled (1 = enabled, 0 = disabled)
DEVICE="$(hyprctl getoption $HYPRLAND_VARIABLE_1 | grep 'int: 1')"

if [ -z "$DEVICE" ]; then
    # if the device is disabled, then enable
    dunstify -u normal "Enabling Touchpad"
    hyprctl keyword $HYPRLAND_VARIABLE_1 true
    hyprctl keyword $HYPRLAND_VARIABLE_2 true
else
    # if the device is enabled, then disable
    dunstify -u normal "Disabling Touchpad"
    hyprctl keyword $HYPRLAND_VARIABLE_1 false
    hyprctl keyword $HYPRLAND_VARIABLE_2 false
fi
