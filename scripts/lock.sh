#!/usr/bin/env sh
# captures monitors and sends blurred output to swaylock
# if SLEEP_SUSPEND is set, suspend is called after locking.
# deps: hyprland jq grim ffmpeg pywal
IMAGES=""
ITER_N=1
while read -r line; do
	grim -g "${line##*:}" -t png /tmp/lock-grim-screen-${ITER_N}.png
	ffmpeg -nostdin -hide_banner -loglevel error -i /tmp/lock-grim-screen-${ITER_N}.png -vf "gblur=sigma=50" -update 1 -y /tmp/lock-blurred-${ITER_N}.png
	IMAGES="$IMAGES --image \"${line%:*}:/tmp/lock-blurred-${ITER_N}.png\""
	ITER_N=$((${ITER_N}+1))
done < <(hyprctl monitors -j | jq  -r '.[] | "\(.name):\(.x),\(.y) \(.width)x\(.height)"')

source "$HOME/.cache/wal/colors.sh"
ARGS="--indicator-radius 160 \
  --indicator-thickness 20 \
  --inside-color 00000000 \
  --inside-clear-color 00000000 \
  --inside-ver-color 00000000 \
  --inside-wrong-color 00000000 \
  --key-hl-color \"$color1\" \
  --bs-hl-color \"$color2\" \
  --ring-color \"$background\" \
  --ring-clear-color \"$color2\" \
  --ring-wrong-color \"$color5\" \
  --ring-ver-color \"$color3\" \
  --line-uses-ring \
  --line-color 00000000 \
  --font 'NotoSans Nerd Font Mono:style=Thin,Regular 40' \
  --text-color 00000000 \
  --text-clear-color 00000000 \
  --text-wrong-color 00000000 \
  --text-ver-color 00000000 \
  --separator-color 00000000 \
  $IMAGES \
  --daemonize"
xargs swaylock <<< "$ARGS"
if [ ! -z "$SLEEP_SUSPEND" ]; then
	systemctl suspend
fi

