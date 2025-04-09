#!/usr/bin/env sh

brightnessctl s 5%-
dunstify -u normal -r 421178002 "Brightness: $((((($(brightnessctl g) * 100)) / $(brightnessctl m))))%"
