{ config, lib, pkgs, username, hyprland, ... }:

{
  imports = [
    ../shared
    hyprland.nixosModules.default
  ];

  home-manager.sharedModules = [
    hyprland.homeManagerModules.default
    ../../hyprland.nix
    ../../waybar.nix
    ../../quickshell.nix
  ];

  system.stateVersion = "25.05";

  networking.networkmanager = {
    enable = true;
    connectionConfig = {
      "ipv6.method" = "disabled";
    };
  };
  networking.enableIPv6 = false;
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
  };
  environment.etc."gai.conf".text = ''
  precedence ::ffff:0:0/96 100
'';

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
  };
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    home = "/home/${username}";
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ username ];
  };


  environment.systemPackages = with pkgs; [
    waybar
    dunst
    swaylock
    swayidle
    wl-clipboard
    grim
    qt6.qtdeclarative  # provides qmlls and qmlformat
    slurp
    pavucontrol
    brightnessctl
    networkmanagerapplet
    slack
    zoom-us
    foot  # fallback terminal
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  nix.gc.dates = "weekly";

  # Hyprland binary cache
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
