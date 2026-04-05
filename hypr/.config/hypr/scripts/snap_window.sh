#!/usr/bin/env bash

MONITOR=$(hyprctl monitors -j)

read -r WIDTH HEIGHT TOP_RESERVED <<< $(echo "$MONITOR" | jq -r '
  .[] | 
  "\((.width / .scale) - 40 | floor) \((.height / .scale) - .reserved[1] - 30 | floor) \(.reserved[1] + 15)"
')

SELECTION=$1
case $SELECTION in
  "left")
    hyprctl dispatch setfloating
    hyprctl dispatch resizeactive exact "$(echo "$WIDTH/2-10" | bc)" "$HEIGHT"
    hyprctl dispatch moveactive exact 20 "$TOP_RESERVED"
    ;;
  "right")
    hyprctl dispatch setfloating
    hyprctl dispatch resizeactive exact "$(echo "$WIDTH/2-10" | bc)" "$HEIGHT"
    hyprctl dispatch moveactive exact "$(echo "$WIDTH/2+35" | bc)" "$TOP_RESERVED"
    ;;
  "top")
    hyprctl dispatch setfloating
    hyprctl dispatch resizeactive exact "$WIDTH" "$(echo "$HEIGHT/2-10" | bc)"
    hyprctl dispatch moveactive exact 20 "$TOP_RESERVED"
    ;;
  "bottom")
    hyprctl dispatch setfloating
    hyprctl dispatch resizeactive exact "$WIDTH" "$(echo "$HEIGHT/2-10" | bc)"
    hyprctl dispatch moveactive exact 20 "$(echo "$HEIGHT/2+$TOP_RESERVED+10" | bc)"
    ;;
esac

