#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/wallpaper"

WALLPAPER=$(ls $WALLPAPER_DIR | grep '.png\|.jpg' | wofi -i --dmenu --prompt 'Select Wallpaper')

if [[ -z "$WALLPAPER" ]]; then
  echo "Not selected wallpaper"
else
  hyprctl hyprpaper reload ,"$WALLPAPER_DIR/$WALLPAPER"
fi
