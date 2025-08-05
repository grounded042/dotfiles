{ pkgs, lib, config, ... }:

let
in
{
  programs.ghostty = {
    enable = true;
    package = null;

    settings = {
      # make alt work for tmux
      keybind = [
        "alt+left=unbind"
        "alt+right=unbind"
      ];

      font-family = "Monaco";
      font-style = "Regular";
      font-size = 12;

      background = "292929";
      foreground = "dee2ea";

      selection-foreground = "dee2ea";
      selection-background = "fc2c1d";

      cursor-color = "c5c5c5";
      cursor-text = "131313";

      title = " ";
      macos-titlebar-proxy-icon = "hidden";
      macos-icon = "xray";

      # Colors can be changed by setting the 16 colors of `palette`, which each color
      # being defined as regular and bold.
      palette = [
        # black
        "0=#292929"
        "8=#494949"
        # red
        "1=#fc2c1d"
        "9=#e74b3b"
        # green
        "2=#2fcc70"
        "10=#07d773"
        # yellow
        "3=#f1c40c"
        "11=#f6c700"
        # blue
        "4=#3398db"
        "12=#0095de"
        # purple
        "5=#6170c4"
        "13=#6667c6"
        # aqua
        "6=#0095de"
        "14=#0092e2"
        # white
        "7=#b9b9b9"
        "15=#d9d9d9"
      ];

      window-padding-x = 2;
      window-padding-y = 2;
      window-theme = "dark";

      copy-on-select = "clipboard";

      custom-shader = "~/.config/ghostty/shaders/cursor.glsl";
      custom-shader-animation = true;
    };
  };
}
