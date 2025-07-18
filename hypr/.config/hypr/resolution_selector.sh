#!/usr/bin/env bash

op=$( echo -e "Standard\n1920x1080" | wofi -i --dmenu )

case $op in 
  Standard)
    hyprctl --batch "keyword monitor ,preferred,auto,1.0666667,bitdepth,10,cm,auto"
    ;;
  1920x1080)
    hyprctl --batch "keyword monitor ,1920x1080,auto,1,bitdepth,10,cm,auto"
    ;;
esac
