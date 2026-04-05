#!/bin/bash

# Get the battery percentage
percentage=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | grep -o '[0-9]*')
status=$(cat /sys/class/power_supply/BAT0/status)

# Define the icons
full_icon=""
three_quarter_icon=""
half_icon=""
one_quarter_icon=""
empty_icon=""
charging_icon=""

if [ "$status" = "Charging" ]; then
    icon="$charging_icon"
else
  if [ "$percentage" -ge 70 ]; then
      icon="$full_icon"
  elif [ "$percentage" -ge 55 ]; then
      icon="$three_quarter_icon"
  elif [ "$percentage" -ge 40 ]; then
      icon="$half_icon"
  elif [ "$percentage" -ge 20 ]; then
      icon="$one_quarter_icon"
  else
      icon="$empty_icon"
  fi
fi

# Output the icon and percentage
echo "$icon $percentage%"
