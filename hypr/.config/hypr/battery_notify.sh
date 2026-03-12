while true; do
  BATTERY_LEVEL=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | grep -o '[0-9]*')
  STATUS=$(cat /sys/class/power_supply/BAT0/status)

  if [ "$STATUS" = "Discharging" ]; then
    case $BATTERY_LEVEL in
      20|15)
        notify-send -a System -i battery-020 "Battery Low" "Battery is at ${BATTERY_LEVEL}%, plug in to a charger soon" -u normal -t 5000
        ;;
      10)
        notify-send -a System -i battery-010 "Battery Very Low" "Battery is at ${BATTERY_LEVEL}%, plug in to a charger now" -u critical -t 7000
        ;;
      8|7|6|5|4|3|2|1|0)
        notify-send -a System -i battery-000 "Battery Critically Low" "Battery is at ${BATTERY_LEVEL}%, plug in to a charger now.\nDevice will shut down without warning" -u critical -t 7000
        ;;
    esac
  fi

  sleep 180
done
