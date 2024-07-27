#!/bin/sh

# It used to be that the wifi_change event supplied an $INFO variable in which
# the current SSID was passed to the script. Due to some MacOS security changes
# it no longer worked, instead we setup $INFO via a networksetup command.
# See https://github.com/FelixKratz/SketchyBar/issues/407#issuecomment-1986867413
INFO="$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' | xargs networksetup -getairportnetwork | sed "s/Current Wi-Fi Network: //")"

WIFI=${INFO:-"Not Connected"}

sketchybar --set $NAME label="${WIFI}"
