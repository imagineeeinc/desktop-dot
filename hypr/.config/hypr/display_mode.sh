#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  op=$( echo -e "Screen1\nMirror\nExtend Above\nExtend Right\nExtend Left\nScreen2" | wofi -i --dmenu )
else
  op=$1
fi

case $op in
  Screen1)
    hyprctl --batch "keyword monitor eDP-1,preferred,0x0,1.0666667"
    hyprctl --batch "keyword monitor HDMI-A-1,disable"
    ;;
  Mirror)
    hyprctl --batch "keyword monitor eDP-1,preferred,0x0,1.0666667"
    hyprctl --batch "keyword monitor HDMI-A-1,1920x1080@100.00,auto,1,mirror,eDP-1"
    ;;
  "Extend Above")
    hyprctl --batch "keyword monitor eDP-1,preferred,0x0,1.0666667"
    hyprctl --batch "keyword monitor HDMI-A-1,1920x1080@100.00,0x-1080,1"
    ;;
  "Extend Right")
    hyprctl --batch "keyword monitor eDP-1,preferred,0x0,1.0666667"
    hyprctl --batch "keyword monitor HDMI-A-1,1920x1080@100.00,1802x0,1"
    ;;
  "Extend Left")
    hyprctl --batch "keyword monitor eDP-1,preferred,0x0,1.0666667"
    hyprctl --batch "keyword monitor HDMI-A-1,1920x1080@100.00,-1920x0,1"
    ;;
  Screen2)
    hyprctl --batch "keyword monitor eDP-1,disable"
    ;;
esac
