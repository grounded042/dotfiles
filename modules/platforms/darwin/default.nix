{ config, lib, pkgs, username, ... }:

{
  imports = [
    ../shared
    ./sketchybar.nix
    ./yabai.nix
    ./system-settings.nix
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
      cleanup = "zap";
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
