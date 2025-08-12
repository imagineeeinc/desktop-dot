#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  op=$( echo -e "Standard\n1920x1080" | wofi -i --dmenu )
else
  op=$1
fi

case $op in 
  Standard)
    hyprctl --batch "keyword monitor eDP-1,preferred,0x0,1.0666667,bitdepth,16,cm,auto"
    ;;
  1920x1080)
    hyprctl --batch "keyword monitor eDP-1,1920x1080,0x0,1,bitdepth,16,cm,auto"
    ;;
  *)
    if [[ -z "$op" ]]; then
      echo "No resolution selected"
    else
      hyprctl --batch "keyword monitor eDP-1,$($op),0x0,1,bitdepth,16,cm,auto"
    fi
  ;;
esac
