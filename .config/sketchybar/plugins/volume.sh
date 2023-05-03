#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

VOLUME=$INFO

output_device_name=$(system_profiler SPAudioDataType -json | jq -r '.SPAudioDataType[0]._items[] | select(.coreaudio_default_audio_output_device == "spaudio_yes") | ._name')

case $VOLUME in
  [6-9][0-9]|100) ICON="􀊩 "
  ;;
  [3-5][0-9]) ICON="􀊧 "
  ;;
  [1-9]|[1-2][0-9]) ICON="􀊥 "
  ;;
  *) ICON="􀊡 "
esac

if [[ "$output_device_name" == *"AirPods Max"* ]]; then
  ICON="􀺹 "
fi

sketchybar --set $NAME icon="$ICON" label="$VOLUME%"
