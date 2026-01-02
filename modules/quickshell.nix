{ config, lib, pkgs, quickshell, ... }:

{
  # Install quickshell package
  home.packages = [
    quickshell.packages.${pkgs.system}.default
  ];

  # Create quickshell config directory
  xdg.configFile."quickshell" = {
    source = ./quickshell;
    recursive = true;
  };
}
