#!/bin/sh

# It used to be that the wifi_change event supplied an $INFO variable in which
# the current SSID was passed to the script. Due to some MacOS security changes
# it no longer worked, instead we setup $INFO via a networksetup command.
# See https://github.com/FelixKratz/SketchyBar/issues/407#issuecomment-1986867413
INFO="$(system_profiler SPAirPortDataType -json | jq -r '.SPAirPortDataType[0].spairport_airport_interfaces[0].spairport_current_network_information._name')"

WIFI=${INFO:-"Not Connected"}

sketchybar --set $NAME label="${WIFI}"
