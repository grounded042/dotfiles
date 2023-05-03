#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# sketchybar --set $NAME label="$(date '+%d/%m %H:%M')"
# Mon, Feb 27, 2023 - 14:33 -0700
sketchybar --set $NAME label="$(date +%Y-%m-%dT%H:%M%z)"

