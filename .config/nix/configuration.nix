{ pkgs, lib, ... }:
{
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

  users = {
    users = {
      joncarl = {
        description = "Jon Carl";
        home = "/Users/joncarl";
        shell = pkgs.zsh;
      };
    };
  };
}
