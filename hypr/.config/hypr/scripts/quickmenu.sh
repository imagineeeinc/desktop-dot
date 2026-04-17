#!/usr/bin/env bash

op=$( echo -e "  Wifi\n Bluetooth\n󰤽 Audio\n󱋆 Monitor Config\n󰍺 Projection Config\n Resume Suspended Applications\n󰸉 Wallaper" | wofi -i --dmenu )

case $op in
  "  Wifi")
    iwmenu --launcher custom --launcher-command "wofi -i --dmenu {password_flag:--password} --prompt '{hint}'"
    ;;
  " Bluetooth")
    bzmenu --launcher custom --launcher-command "wofi -i --dmenu --prompt '{hint}'"
    ;;
  "󰤽 Audio")
    pwmenu --launcher custom --launcher-command "wofi -i --dmenu --prompt '{hint}'"
    ;;
  "󰸉 Wallaper")
    ~/.config/hypr/scripts/wofi_wallpaper_selector.sh
    ;;
  "󱋆 Monitor Config")
    python -m fabric execute Widgets "monitor_resolution.show()"
    ;;
  "󰍺 Projection Config")
    python -m fabric execute Widgets "monitor_settings.show()"
    ;;
  " Resume Suspended Applications")
    ~/.config/hypr/scripts/freeze.sh unfreeze
    ;;
esac

