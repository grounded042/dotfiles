{ config, lib, pkgs, username, ... }:

{
  programs.zsh.enable = true;

  nix = {
    settings = {
      allowed-users = [username];
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  users = {
    users = {
      ${username} = {
        description = "Jon Carl";
        shell = pkgs.zsh;
      };
    };
  };
}
