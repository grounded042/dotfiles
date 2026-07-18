{ config, lib, pkgs, quickshell, ... }:

{
  # Install quickshell package
  home.packages = [
    quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Create quickshell config directory
  xdg.configFile."quickshell" = {
    source = ./quickshell;
    recursive = true;
  };
}
