{
  pkgs,
  lib,
  username,
  ...
}: {
  system.defaults = {
    # Disable the "Are you sure you want to open this application?" dialog
    LaunchServices = {
      LSQuarantine = false;
    };

    # System-wide settings that require admin privileges
    screensaver = {
      # Require password immediately after sleep or screen saver begins
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    # Save screenshots to the desktop
    screencapture = {
      location = "~/Desktop";
      # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
      type = "png";
      # Disable shadow in screenshots
      disable-shadow = true;
    };

    # System-wide CustomUserPreferences that affect system behavior
    CustomUserPreferences = {
      "com.apple.SoftwareUpdate" = {
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
      };
      "com.apple.dashboard" = {
        # Disable Dashboard
        mcx-disabled = true;
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.NetworkBrowser" = {
        # Enable AirDrop over Ethernet and on unsupported Macs running Lion
        BrowseAllInterfaces = true;
      };
      "com.apple.systempreferences" = {
        # Disable Resume system-wide
        NSQuitAlwaysKeepsWindows = false;
      };
      "com.apple.print.PrintingPrefs" = {
        # Automatically quit printer app once the print jobs complete
        "Quit When Finished" = true;
      };
      "com.apple.BluetoothAudioAgent" = {
        # Increase sound quality for Bluetooth headphones/headsets
        "Apple Bitpool Min (editable)" = 40;
      };
    };
  };

  # System settings that can't be handled by system.defaults
  system.activationScripts.postActivation = {
    enable = true;
    text = ''
      # Show the ~/Library folder (as user)
      sudo -u ${username} chflags nohidden /Users/${username}/Library 2>/dev/null || true
      # Show the /Volumes folder (system-wide)
      chflags nohidden /Volumes 2>/dev/null || true

      # Remove duplicates in the "Open With" menu (system-wide)
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user 2>/dev/null || true
    '';
  };
}
