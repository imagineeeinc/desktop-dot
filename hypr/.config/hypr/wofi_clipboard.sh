#!/usr/bin/env bash

SELECTION=$(cliphist list | wofi --dmenu)

if [[ -z "$SELECTION" ]]; then
  echo "Not selected anything"
else
  echo "$SELECTION" | cliphist decode | wl-copy
fi
