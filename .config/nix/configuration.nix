{ pkgs, lib, ... }:
let
  currentSystem = import ./current_system.nix;
in
{
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

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
