{ config, lib, pkgs, username, ... }:

{
  programs.zsh.enable = true;

  nix = lib.mkIf config.nix.enable {
    settings = {
      allowed-users = [username];
      experimental-features = ["nix-command" "flakes"];
      max-jobs = "auto";
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
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
