{
  pkgs,
  lib,
  username,
  ...
}:
let
  # Import system-specific configuration
  currentSystem = import ./current_system.nix;

  # for modifier support, check https://github.com/LnL7/nix-darwin/issues/998
  hotCornerModifiers = {
    none = 0;
    option = 524288;
    cmd = 1048576;
    "option+cmd" = 1573864;
  };
  hotCornerActions = {
    disabled = null;
    missionControl = 2;
    applicationWindows = 3;
    desktop = 4;
    startScreenSaver = 5;
    disableScreenSaver = 6;
    dashboard = 7;
    putDisplayToSleep = 10;
    launchpad = 11;
    notificationCenter = 12;
  };
  activityMonitorCategories = {
    none = null;
    allProcesses = 100;
    allProcessesHierarchally = 101;
    myProcesses = 102;
    systemProcesses = 103;
    otherUserProcesses = 104;
    activeProcesses = 105;
    inactiveProcesses = 106;
    windowedProcesses = 107;
  };
in
{
  imports = [
    currentSystem.configuration
    ./modules/sketchybar.nix
    ./modules/yabai.nix
    ./modules/system.nix
  ];

  programs.zsh.enable = true;
  system.stateVersion = 6;
  ids.gids.nixbld = 30000;
  nixpkgs.config.allowUnfree = true;

  users = {
    users = {
      ${username} = {
        description = "Jon Carl";
        home = "/Users/${username}";
        shell = pkgs.zsh;
      };
    };
  };

  system.primaryUser = username;

}
