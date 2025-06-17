{
  pkgs,
  lib,
  username,
  ...
}:

let
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
  targets.darwin.defaults = {
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
      AppleMetricUnits = false;

      # Finder: show all filename extensions
      AppleShowAllExtensions = true;

      # Enable spring loading for directories
      "com.apple.springing.enabled" = true;

      # Enable subpixel font rendering on non-Apple LCDs
      # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
      AppleFontSmoothing = 1;

      # Adjust toolbar title rollover delay
      NSToolbarTitleViewRolloverDelay = 0.0;
      # Set language and text formats
      AppleLanguages = [ "en" ];
      AppleLocale = "en_US@currency=USD";
      # Add a context menu item for showing the Web Inspector in web views
      WebKitDeveloperExtras = true;
    };

    "com.apple.finder" = {
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

      # Empty Trash securely by default
      EmptyTrashSecurely = true;
    };

    "com.apple.dock" = {
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

      # Hot corner modifiers
      wvous-tl-modifier = hotCornerModifiers.none;
      wvous-bl-modifier = hotCornerModifiers.none;
      wvous-tr-modifier = hotCornerModifiers.none;
      wvous-br-modifier = hotCornerModifiers.none;

      # Don't show Dashboard as a Space
      dashboard-in-overlay = true;
    };

    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      # Trackpad: enable tap to click for this user and for the login screen
      Clicking = true;
      TrackpadRightClick = true;
      # Trackpad: map bottom right corner to right-click
      TrackpadCornerSecondaryClick = 2;
    };

    "com.apple.ActivityMonitor" = {
      # Show the main window when launching Activity Monitor
      OpenMainWindow = true;
      # Visualize CPU usage in the Activity Monitor Dock icon
      IconType = 5;
      ShowCategory = activityMonitorCategories.allProcesses;
      # Sort Activity Monitor results by CPU usage
      SortColumn = "CPUUsage";
      SortDirection = 0;
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

    "com.apple.helpviewer" = {
      # Set Help Viewer windows to non-floating mode
      DevMode = true;
    };
  };
}
