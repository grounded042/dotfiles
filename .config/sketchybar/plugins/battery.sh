#!/bin/sh

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  100) ICON="􀛨"
  ;;
  [8-9][0-9]) ICON="􀺸"
  ;;
  [7][5-9]) ICON="􀺸"
  ;;
  [7][0-4]) ICON="􀺶"
  ;;
  [5-6][0-9]) ICON="􀺶"
  ;;
  [3-4][0-9]) ICON="􀛪"
  ;;
  [2][5-9]) ICON="􀛪"
  ;;
  [2][0-4]) ICON="􀛪"
  ;;
  [1][0-9]) ICON="􀛪"
  ;;
  *) ICON="􀛪"
esac

if [[ $CHARGING != "" ]]; then
  ICON="􀢋"
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"
