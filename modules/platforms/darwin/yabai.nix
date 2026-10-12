{
  currentSystem,
  pkgs,
  lib,
  ...
}: let
  nativeBarEnabled = (currentSystem.statusBar or "sketchybar") == "nativebar";
in {
  services.yabai = {
    enable = true;
    config = {
      # top bar
      # NativeBar occupies a flush 38-point strip at the top of the display.
      external_bar =
        if nativeBarEnabled
        then "all:38:0"
        else "all:26:0";

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
      top_padding =
        if nativeBarEnabled
        then 10
        else 24;
      bottom_padding =
        if nativeBarEnabled
        then 10
        else 20;
      left_padding =
        if nativeBarEnabled
        then 10
        else 20;
      right_padding =
        if nativeBarEnabled
        then 10
        else 20;
      window_gap = 10;
    };
    extraConfig = ''
      # rules
      yabai -m rule --add app="^(System Preferences|System Settings)$" manage=off
      yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
      yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
    '';
  };
}
