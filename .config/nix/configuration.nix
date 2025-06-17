{
  pkgs,
  lib,
  username,
  ...
}:
let
  # Import system-specific configuration
  currentSystem = import ./current_system.nix;
in
{
  imports = [
    currentSystem.configuration
    ./modules/sketchybar.nix
    ./modules/yabai.nix
    ./modules/system-settings.nix
  ];

  programs.zsh.enable = true;
  system.stateVersion = 6;
  ids.gids.nixbld = 30000;
  nixpkgs.config.allowUnfree = true;

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

  users = {
    users = {
      ${username} = {
        description = "Jon Carl";
        home = "/Users/${username}";
        shell = pkgs.zsh;
      };
    };
  };

  system.primaryUser = username;

}
