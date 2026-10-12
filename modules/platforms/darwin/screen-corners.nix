{
  currentSystem,
  lib,
  pkgs,
  ...
}: let
  enabled = currentSystem.screenCorners or false;
in {
  environment.systemPackages = lib.optionals enabled [pkgs.screen-corners];

  launchd.user.agents.screen-corners = lib.mkIf enabled {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.screen-corners}/Applications/ScreenCorners.app/Contents/MacOS/ScreenCorners"
      ];
      KeepAlive = true;
      ProcessType = "Interactive";
      RunAtLoad = true;
    };
  };
}
