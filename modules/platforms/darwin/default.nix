{
  config,
  currentSystem,
  lib,
  pkgs,
  username,
  ...
}: let
  statusBar = currentSystem.statusBar or "sketchybar";
in {
  imports = [
    ./nativebar.nix
    ./screen-corners.nix
    ../shared
    ./sketchybar.nix
    ./yabai.nix
    ./system-settings.nix
  ];

  assertions = [
    {
      assertion = builtins.elem statusBar ["sketchybar" "nativebar" "none"];
      message = ''
        currentSystem.statusBar must be "sketchybar", "nativebar", or "none";
        got ${builtins.toJSON statusBar}
      '';
    }
  ];

  system.stateVersion = 6;
  ids.gids.nixbld = 30000;

  nix.gc.interval = {
    Weekday = 0;
    Hour = 2;
    Minute = 0;
  }; # Sunday 2 AM

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "none";
    };
    global = {
      autoUpdate = false;
    };
  };

  users.users.${username}.home = "/Users/${username}";
  system.primaryUser = username;

  # Add Darwin-specific Home Manager modules
  home-manager.sharedModules = [
    ./user-defaults.nix
  ];
}
