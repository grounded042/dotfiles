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

  services.yabai = {
    enable = true;
    config = {
      # top bar
      external_bar = "all:26:0";

      # global settings
      mouse_follows_focus = "off";
      focus_follows_mouse = "autoraise";
      window_placement = "second_child";
      window_topmost = "off";
      window_opacity = "off";
      window_shadow = "on";
      window_border = "off";
      split_ratio = 0.50;
      auto_balance = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";

      # general space settings
      layout = "bsp";
      top_padding = 24;
      bottom_padding = 20;
      left_padding = 20;
      right_padding = 20;
      window_gap = 10;
    };
    extraConfig = ''
      # events
      yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus &> /dev/null"
      yabai -m signal --add event=window_title_changed action="sketchybar --trigger title_change &> /dev/null"

      # rules
      yabai -m rule --add app="^(System Preferences|System Settings)$" manage=off
      yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
      yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
    '';
  };

  system.primaryUser = username;

  system.defaults = {
    NSGlobalDomain = {
      # Expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Expand print panel by default
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;

      # Disable automatic termination of inactive apps
      NSDisableAutomaticTermination = true;

      # Disable automatic capitalization as it's annoying when typing code
      NSAutomaticCapitalizationEnabled = false;

      # Disable smart dashes as they're annoying when typing code
      NSAutomaticDashSubstitutionEnabled = false;

      # Disable automatic period substitution as it's annoying when typing code
      NSAutomaticPeriodSubstitutionEnabled = false;

      # Disable smart quotes as they're annoying when typing code
      NSAutomaticQuoteSubstitutionEnabled = false;

      # Disable auto-correct
      NSAutomaticSpellingCorrectionEnabled = false;

      # Trackpad: enable tap to click for this user and for the login screen
      "com.apple.mouse.tapBehavior" = 1;

      # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
      AppleKeyboardUIMode = 3;

      # Disable press-and-hold for keys in favor of key repeat
      ApplePressAndHoldEnabled = false;

      # Set language and text formats
      AppleMeasurementUnits = "Inches";
      AppleMetricUnits = 0;

      # Finder: show all filename extensions
      AppleShowAllExtensions = true;

      # Enable spring loading for directories
      "com.apple.springing.enabled" = true;

      # Enable subpixel font rendering on non-Apple LCDs
      # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
      AppleFontSmoothing = 1;
    };

    # Disable the "Are you sure you want to open this application?" dialog
    LaunchServices = {
      LSQuarantine = false;
    };

    finder = {
      # Show icons for hard drives, servers, and removable media on the desktop
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;

      # Finder: show hidden files by default
      AppleShowAllFiles = true;

      # Finder: show status bar
      ShowStatusBar = true;

      # Finder: show path bar
      ShowPathbar = true;

      # Display full POSIX path as Finder window title
      _FXShowPosixPathInTitle = true;

      # Keep folders on top when sorting by name
      _FXSortFoldersFirst = true;

      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";

      # Disable the warning when changing a file extension
      FXEnableExtensionChangeWarning = false;
    };

    dock = {
      # Enable highlight hover effect for the grid view of a stack (Dock)
      mouse-over-hilite-stack = true;

      # Set the icon size of Dock items to 36 pixels
      tilesize = 36;

      # Turn on Dock magnification
      magnification = true;

      # Enable spring loading for all Dock items
      enable-spring-load-actions-on-all-items = true;

      # Show indicator lights for open applications in the Dock
      show-process-indicators = true;

      # Show only open applications in the Dock
      static-only = true;

      # Don't automatically rearrange Spaces based on most recent use
      mru-spaces = false;

      # Don't show recent applications in Dock
      show-recents = false;

      # Hot Corners
      wvous-tl-corner = hotCornerActions.missionControl;
      wvous-bl-corner = hotCornerActions.applicationWindows;
      wvous-tr-corner = hotCornerActions.disabled;
      wvous-br-corner = hotCornerActions.notificationCenter;
    };

    trackpad = {
      # Trackpad: enable tap to click for this user and for the login screen
      Clicking = true;
      TrackpadRightClick = true;
    };

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

    ActivityMonitor = {
      # Show the main window when launching Activity Monitor
      OpenMainWindow = true;
      # Visualize CPU usage in the Activity Monitor Dock icon
      IconType = 5;
      ShowCategory = activityMonitorCategories.allProcesses;
      # Sort Activity Monitor results by CPU usage
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    # Custom user preferences for settings not available in standard system.defaults
    CustomUserPreferences = {
      "com.apple.dock" = {
        # Hot corner modifiers
        wvous-tl-modifier = hotCornerModifiers.none;
        wvous-bl-modifier = hotCornerModifiers.none;
        wvous-tr-modifier = hotCornerModifiers.none;
        wvous-br-modifier = hotCornerModifiers.none;
      };
      "com.apple.mail" = {
        # Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
        AddressesIncludeNameOnPasteboard = false;
        # Disable inline attachments (just show the icons)
        DisableInlineAttachmentViewing = true;
      };
      "com.apple.Safari" = {
        # Privacy: don't send search queries to Apple
        UniversalSearchEnabled = false;
        SuppressSearchSuggestions = true;

        # Press Tab to highlight each item on a web page
        WebKitTabToLinksPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;

        # Show the full URL in the address bar (note: this still hides the scheme)
        ShowFullURLInSmartSearchField = true;

        # Set Safari's home page to `about:blank` for faster loading
        HomePage = "about:blank";

        # Prevent Safari from opening 'safe' files automatically after downloading
        AutoOpenSafeDownloads = false;

        # Hide Safari's bookmarks bar by default
        ShowFavoritesBar = false;

        # Hide Safari's sidebar in Top Sites
        ShowSidebarInTopSites = false;

        # Disable Safari's thumbnail cache for History and Top Sites
        DebugSnapshotsUpdatePolicy = 2;

        # Enable Safari's debug menu
        IncludeInternalDebugMenu = true;

        # Make Safari's search banners default to Contains instead of Starts With
        FindOnPageMatchesWordStartsOnly = false;

        # Remove useless icons from Safari's bookmarks bar
        ProxiesInBookmarksBar = "()";

        # Enable the Develop menu and the Web Inspector in Safari
        IncludeDevelopMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;

        # Enable continuous spellchecking
        WebContinuousSpellCheckingEnabled = true;

        # Disable auto-correct
        WebAutomaticSpellingCorrectionEnabled = false;

        # Warn about fraudulent websites
        WarnAboutFraudulentWebsites = true;

        # Disable Java
        WebKitJavaEnabled = false;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;

        # Block pop-up windows
        WebKitJavaScriptCanOpenWindowsAutomatically = false;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;

        # Enable "Do Not Track"
        SendDoNotTrackHTTPHeader = true;

        # Update extensions automatically
        InstallExtensionUpdatesAutomatically = true;
      };
      "com.apple.terminal" = {
        # Only use UTF-8 in Terminal.app
        StringEncodings = [ 4 ];
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        # Trackpad: map bottom right corner to right-click
        TrackpadCornerSecondaryClick = 2;
      };
      # Settings that were in postUserActivation
      "NSGlobalDomain" = {
        # Adjust toolbar title rollover delay
        NSToolbarTitleViewRolloverDelay = 0.0;
        # Set language and text formats
        AppleLanguages = [ "en" ];
        AppleLocale = "en_US@currency=USD";
        # Add a context menu item for showing the Web Inspector in web views
        WebKitDeveloperExtras = true;
      };
      "com.apple.SoftwareUpdate" = {
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
      };
      "com.apple.dashboard" = {
        # Disable Dashboard
        mcx-disabled = true;
      };
      "com.apple.dock" = {
        # Don't show Dashboard as a Space
        dashboard-in-overlay = true;
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.finder" = {
        # Empty Trash securely by default
        EmptyTrashSecurely = true;
      };
      "com.apple.NetworkBrowser" = {
        # Enable AirDrop over Ethernet and on unsupported Macs running Lion
        BrowseAllInterfaces = true;
      };
      "com.apple.helpviewer" = {
        # Set Help Viewer windows to non-floating mode
        DevMode = true;
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
