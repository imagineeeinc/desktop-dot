#!/usr/bin/env bash

SELECTION=$(cliphist list | wofi --dmenu --prompt "Search History")

if [[ -z "$SELECTION" ]]; then
  echo "Not selected anything"
else
  echo "$SELECTION" | cliphist decode | wl-copy
fi
