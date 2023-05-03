#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

json=$(yabai -m query --windows --window)
app=$(echo "$json" | jq -r .app)
title=$(echo "$json" | jq -r .title)

if [[ ${#title} -gt 75 ]]; then
  title=$(echo "$title" | cut -c 1-75)...
fi

sketchybar --set $NAME label="$title"
