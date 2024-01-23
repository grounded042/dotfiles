{ pkgs, lib, ... }:
{
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;

  users = {
    users = {
      "jon.carl" = {
        description = "Jon Carl";
        home = "/Users/jon.carl";
        shell = pkgs.zsh;
      };
    };
  };
}
