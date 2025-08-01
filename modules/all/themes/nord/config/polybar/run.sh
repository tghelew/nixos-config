#!/usr/bin/env bash

# Terminate already running bar instances
pkill -u $UID -x polybar

# Wait until the processes have been shut down
while pgrep -q-u $UID -x polybar >/dev/null; do sleep 1; done

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main &
  done
else
  polybar --reload main &
fi

echo "Bars launched..."
