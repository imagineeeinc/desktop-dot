#!/bin/bash

# Function to handle the events
handle_event() {
  # Event format: activewindowv2>>[address]
  if [[ $1 == activewindowv2* ]]; then
    # Get the current workspace name/ID
    # We use -j for JSON parsing to get the workspace of the active window safely
    WORKSPACE_NAME=$(hyprctl activewindow -j | jq -r '.workspace.name')
    if [ "$WORKSPACE_NAME" = "special:minimize" ]; then
      # Move the window to the current "visible" workspace
      # 'm+0' refers to the current monitor's active workspace
      hyprctl dispatch movetoworkspace m+0
    fi
  fi
}

# Listen to Hyprland events via socat
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle_event "$line"
done
