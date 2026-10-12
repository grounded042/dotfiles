{
  currentSystem,
  lib,
  pkgs,
  ...
}: let
  enabled = (currentSystem.statusBar or "sketchybar") == "nativebar";
in {
  environment.systemPackages = lib.optionals enabled [pkgs.nativebar];

  launchd.user.agents.nativebar = lib.mkIf enabled {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.nativebar}/Applications/NativeBar.app/Contents/MacOS/NativeBar"
      ];
      KeepAlive = true;
      ProcessType = "Interactive";
      RunAtLoad = true;
    };
  };
}
