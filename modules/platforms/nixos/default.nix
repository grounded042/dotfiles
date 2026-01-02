{ config, lib, pkgs, username, ... }:

{
  imports = [
    ../shared
  ];

  home-manager.sharedModules = [
    ../../hyprland.nix
    ../../waybar.nix
    ../../quickshell.nix
  ];

  system.stateVersion = "25.05";

  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
  };
  programs.hyprland.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
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
    zoom-us
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  nix.gc.dates = "weekly";
}
