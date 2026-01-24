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

  # Enable OpenGL with Mesa 25.3 from unstable
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    package = pkgs.mesa;
    package32 = pkgs.pkgsi686Linux.mesa;
  };

  # Enable Docker
  virtualisation.docker = {
    enable = true;
  };

  # Enable Steam
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
}
