{ config, pkgs, lib, ... }:
{
  # TODO: move zshrc options into here
  # programs.zsh = { enable = true; };

  home.stateVersion = "22.05";

  home.username = "joncarl";
  home.homeDirectory = "/Users/joncarl";

  home.packages = [
    pkgs.nodejs
  ];

  home.sessionVariables = {
    HELLO = "world";
  };
}
