{ pkgs, lib, ... }:
let
  currentSystem = import ./current_system.nix;
in
{
  imports = [
    currentSystem.configuration
  ];

  programs.zsh.enable = true;
  system.stateVersion = 6;
  ids.gids.nixbld = 30000;
  nixpkgs.config.allowUnfree = true;

  users = {
    users = {
      ${currentSystem.username} = {
        description = "Jon Carl";
        home = "/Users/${currentSystem.username}";
        shell = pkgs.zsh;
      };
    };
  };
}
