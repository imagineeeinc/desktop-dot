#!/bin/bash
if pgrep -x "pavucontrol --tab 3" > /dev/null
then
    pkill -x "pavucontrol"
else
    pavucontrol &
fi
