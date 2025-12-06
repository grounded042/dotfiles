{
  pkgs,
  lib,
  ...
}: {
  services.yabai = {
    enable = true;
    config = {
      # top bar
      external_bar = "all:26:0";

      # global settings
      mouse_follows_focus = "off";
      focus_follows_mouse = "autoraise";
      window_placement = "second_child";
      window_topmost = "off";
      window_opacity = "off";
      window_shadow = "on";
      window_border = "off";
      split_ratio = 0.50;
      auto_balance = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";

      # general space settings
      layout = "bsp";
      top_padding = 24;
      bottom_padding = 20;
      left_padding = 20;
      right_padding = 20;
      window_gap = 10;
    };
    extraConfig = ''
      # events
      yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus &> /dev/null"
      yabai -m signal --add event=window_title_changed action="sketchybar --trigger title_change &> /dev/null"

      # rules
      yabai -m rule --add app="^(System Preferences|System Settings)$" manage=off
      yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
      yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
    '';
  };
}
