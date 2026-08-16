{
  pkgs,
  lib,
  currentSystem,
  ...
}: let
  enabled = currentSystem.enableNono or false;
in {
  home.packages = lib.mkIf enabled [pkgs.nono];
}
