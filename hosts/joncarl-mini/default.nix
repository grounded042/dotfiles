{ config, lib, pkgs, username, ... }:

{
  networking.hostName = "joncarl-mini";

  nix.enable = false;

  system.defaults.CustomUserPreferences."com.apple.SoftwareUpdate" = {
    AutomaticCheckEnabled = true;
    AutomaticDownload = true;
    AutomaticallyInstallMacOSUpdates = false;
    ConfigDataInstall = true;
    CriticalUpdateInstall = true;
  };
}
