{ pkgs, lib, ... }:

let
  # Plugin scripts that will be put in the nix store
  plugins = {
    battery = pkgs.writeShellScript "battery.sh" ''
      #!/bin/sh

      PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
      CHARGING=$(pmset -g batt | grep 'AC Power')

      if [ $PERCENTAGE = "" ]; then
        exit 0
      fi

      case ''${PERCENTAGE} in
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
      sketchybar --set $NAME icon="$ICON" label="''${PERCENTAGE}%"
    '';

    clock = pkgs.writeShellScript "clock.sh" ''
      #!/bin/sh

      # The $NAME variable is passed from sketchybar and holds the name of
      # the item invoking this script:
      # https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

      # sketchybar --set $NAME label="$(date '+%d/%m %H:%M')"
      # Mon, Feb 27, 2023 - 14:33 -0700
      sketchybar --set $NAME label="$(date +%Y-%m-%dT%H:%M%z)"
    '';

    front_app = pkgs.writeShellScript "front_app.sh" ''
      #!/bin/sh

      # Some events send additional information specific to the event in the $INFO
      # variable. E.g. the front_app_switched event sends the name of the newly
      # focused application in the $INFO variable:
      # https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

      json=$(yabai -m query --windows --window)
      app=$(echo "$json" | ${pkgs.jq}/bin/jq -r .app)
      title=$(echo "$json" | ${pkgs.jq}/bin/jq -r .title)

      if [[ ''${#title} -gt 75 ]]; then
        title=$(echo "$title" | cut -c 1-75)...
      fi

      sketchybar --set $NAME label="$title"
    '';

    space = pkgs.writeShellScript "space.sh" ''
      #!/bin/sh

      # The $SELECTED variable is available for space components and indicates if
      # the space invoking this script (with name: $NAME) is currently selected:
      # https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

      sketchybar --set $NAME label.highlight=$SELECTED
    '';

    volume = pkgs.writeShellScript "volume.sh" ''
      #!/bin/sh

      # The volume_change event supplies a $INFO variable in which the current volume
      # percentage is passed to the script.

      VOLUME=$INFO

      output_device_name=$(system_profiler SPAudioDataType -json | ${pkgs.jq}/bin/jq -r '.SPAudioDataType[0]._items[] | select(.coreaudio_default_audio_output_device == "spaudio_yes") | ._name')

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
    '';

    wifi = pkgs.writeShellScript "wifi.sh" ''
      #!/bin/sh

      # It used to be that the wifi_change event supplied an $INFO variable in which
      # the current SSID was passed to the script. Due to some MacOS security changes
      # it no longer worked, instead we setup $INFO via a networksetup command.
      # See https://github.com/FelixKratz/SketchyBar/issues/407#issuecomment-1986867413
      INFO="$(system_profiler SPAirPortDataType -json | ${pkgs.jq}/bin/jq -r '.SPAirPortDataType[0].spairport_airport_interfaces[0].spairport_current_network_information._name')"

      WIFI=''${INFO:-"Not Connected"}

      sketchybar --set $NAME label="''${WIFI}"
    '';
  };
in
{
  services.sketchybar = {
    enable = true;
    config = ''
      sketchybar --bar height=32        \
                       position=top     \
                       sticky=off       \
                       padding_left=10  \
                       padding_right=10 \
                       color=0xff202020 \
                       shadow=true

      sketchybar --default icon.font="SF Pro:Semibold:15.0"  \
                           icon.color=0xffffffff                 \
                           label.font="SF Pro:Semibold:13.0" \
                           label.color=0xffffffff                \
                           label.highlight_color=0xffe60000      \
                           padding_left=5                        \
                           padding_right=5                       \
                           label.padding_left=4                  \
                           label.padding_right=4                 \
                           icon.padding_left=4                   \
                           icon.padding_right=4

      SPACE_ICONS=("I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X")

      for i in ''${!SPACE_ICONS[@]}
      do
        sid=$(($i+1))
        sketchybar --add space space.$sid left                                 \
                   --set space.$sid associated_space=$sid                      \
                                    label=''${SPACE_ICONS[i]}                     \
                                    label.highlight=off                     \
                                    background.color=0x44ffffff                \
                                    background.corner_radius=5                 \
                                    background.height=20                       \
                                    background.drawing=off                     \
                                    icon.drawing=off                          \
                                    script="${plugins.space}"                  \
                                    click_script="yabai -m space --focus $sid"
      done

      ##### Adding Left Items #####
      # We add some regular items to the left side of the bar
      # only the properties deviating from the current defaults need to be set

      # sketchybar --add item space_separator left                         \
      #            --set space_separator icon=􀛨                            \
      #                                  padding_left=10                   \
      #                                  padding_right=10                  \
      #                                  label.drawing=off

      sketchybar --add event window_focus                            \
                 --add event title_change                            \
                 --add item title center                             \
                 --set title       script="${plugins.front_app}"     \
                 --subscribe title front_app_switched window_focus title_change

      ##### Adding Right Items #####
      # In the same way as the left items we can add items to the right side.
      # Additional position (e.g. center) are available, see:
      # https://felixkratz.github.io/SketchyBar/config/items#adding-items-to-sketchybar

      # Some items refresh on a fixed cycle, e.g. the clock runs its script once
      # every 10s. Other items respond to events they subscribe to, e.g. the
      # volume.sh script is only executed once an actual change in system audio
      # volume is registered. More info about the event system can be found here:
      # https://felixkratz.github.io/SketchyBar/config/events

      sketchybar --add item clock right                              \
                 --set clock   update_freq=10                        \
                               icon=􀐫                                \
                               script="${plugins.clock}"             \
                                                                     \
                 --add item wifi right                               \
                 --set wifi    script="${plugins.wifi}"              \
                               icon=􀙇                               \
                 --subscribe wifi wifi_change                        \
                                                                     \
                 --add item volume right                             \
                 --set volume  script="${plugins.volume}"            \
                 --subscribe volume volume_change                    \
                                                                     \
                 --add item battery right                            \
                 --set battery script="${plugins.battery}"           \
                               update_freq=120                       \
                 --subscribe battery system_woke power_source_change

      ##### Finalizing Setup #####
      # The below command is only needed at the end of the initial configuration to
      # force all scripts to run the first time, it should never be run in an item script.

      sketchybar --update
    '';
  };
}
