#!/usr/bin/env bash

SUSPENDED=$(hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:suspend") | "\(.title) | \(.address)"')

SELECTION=$1
case $SELECTION in
  "freeze")
    ~/.local/bin/hyprfreeze -a
    hyprctl dispatch movetoworkspacesilent special:suspend
    ;;
  "unfreeze")
    echo $SUSPENDED
    WINDOW=$(echo "$SUSPENDED" | wofi --dmenu --prompt "Select Window to Resume")
    if [ -n "$WINDOW" ]; then
      ADDRESS=$(echo "$WINDOW" | awk -F ' | ' '{print $NF}')
      hyprctl dispatch movetoworkspace "+0,address:$ADDRESS"
      ~/.local/bin/hyprfreeze -a
    fi
    ;;
esac
