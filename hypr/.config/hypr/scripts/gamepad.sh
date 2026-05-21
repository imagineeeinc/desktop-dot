#!/usr/bin/env bash

connected=false

is_real_controller() {
  local dev=$1
  local name=$(udevadm info -a -n "$dev" | grep 'ATTRS{name}' | head -n1 | cut -d'"' -f2)
  case "$name" in
    *"Mouse passthrough"*) return 1 ;;
    *"Sunshine"*)          return 1 ;;
    *"uinput"*)            return 1 ;;
    "")                    return 1 ;;
    *)                     return 0 ;;
  esac
}

count_real_joysticks() {
  local count=0
  for js in /dev/input/js*; do
    [ -c "$js" ] || continue
    if is_real_controller "$js"; then
      ((count++))
    fi
  done
  echo "$count"
}

on_connected() {
  op=$( echo -e "󰑈  Big Picture\n󰓓 Steam\n󱢾 Heroic\n Lutris\n Desktop" | wofi -i --dmenu --prompt "Select a gaming mode" )
  local choose="Desktop"
  local icon="stadia"
  case $op in
    "󰑈  Big Picture")
      steam steam://open/bigpicture &
      choose="Big Picture Mode"
      icon="tv"
      ;;
    "󰓓 Steam")
      steam steam://open/library &
      choose="Steam"
      icon="steam"
      ;;
    "󱢾 Heroic")
      flatpak run com.heroicgameslauncher.hgl --console &
      choose="Heroic"
      ;;
    " Lutris")
      lutris &
      choose="Lutris"
      icon="net.lutris.Lutris"
      ;;
    " Desktop")
      echo "Desktop mode"
      ;;
  esac
  notify-send -a Gamepad -i $icon -n ~/.config/swaync/megastar.png "Gamepad connected" "Launching ${choose}"
}

while true; do
  real_count=$(count_real_joysticks)
  if [ "$real_count" -gt 0 ] && [ "$connected" = false ]; then
    echo "Physical controller detected"
    on_connected
    connected=true
  elif [ "$real_count" -eq 0 ] && [ "$connected" = true ]; then
    echo "Physical controller disconnected."
    steam steam://close/bigpicture &
    flatpak kill com.heroicgameslauncher.hgl &
    pkill lutris &
    notify-send -a Gamepad -i stadia -n ~/.config/swaync/megastar.png "Gamepad disconnected" "Closing game launchers"
    connected=false
  fi
  sleep 1
done

