{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.ack
      pkgs.antibody
      pkgs.automake
      pkgs.bat
      pkgs.cmake
      pkgs.direnv
      pkgs.exa
      pkgs.findutils
      pkgs.fzf
      pkgs.git
      pkgs.gnugrep
      pkgs.gnupg
      pkgs.gnused
      pkgs.go
      pkgs.hugo
      pkgs.jq
      pkgs.lua
      pkgs.moreutils
      pkgs.nmap
      pkgs.tmux
      pkgs.yadm
      pkgs.yq
      pkgs.zsh
      pkgs.zsh-syntax-highlighting

      #pkgs.yabai
      #pkgs.skhd
      #pkgs.spacebar

      pkgs.neovim
    ];

  # services.yabai = {
  #   enable = true;
  #   package = pkgs.yabai;
  # };

  # services.spacebar = {
  #   enable = true;
  #   package = pkgs.spacebar;
  # };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
