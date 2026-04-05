#!/bin/bash

# 1. Get the binds from hyprctl in JSON format
# 2. Use jq to filter for binds that have a description
# 3. Format the output for wofi: "Description (Mod+Key)"
binds=$(hyprctl binds -j | jq -r '.[] | select(.has_description == true) | "\(.description) [\(.modmask) + \(.key)], \(.dispatcher) \(.arg)"')
# 4. Present the list via wofi and capture the selection
selection=$(echo "$binds" | cut -d'|' -f1 | wofi --dmenu --prompt "Execute Command...")

# 5. Extract the dispatcher and arguments from the original list based on the selection
if [ -n "$selection" ]; then
    # Get the command part after the pipe for the matching description
    command=$(echo "$selection" | cut -d',' -f2)
    echo "$command"
    # Execute the command via hyprctl
    hyprctl dispatch $command
fi
