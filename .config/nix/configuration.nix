{ pkgs, lib, ... }:
let
  currentSystem = import ./current_system.nix;
in
{
  programs.zsh.enable = true;
  system.stateVersion = 6;
  ids.gids.nixbld = 30000;

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
