{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "pollux";
  time.timeZone = "America/Denver";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Use kernel 6.18
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  services.xserver.videoDrivers = [ "amdgpu" ];

  # RDNA 4 (RX 9070 XT) - Mesa 25.2.6 from nixos-25.11 (RADV is default)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };

  # Enable Docker
  virtualisation.docker = {
    enable = true;
  };

  # Enable Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
