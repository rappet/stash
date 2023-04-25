# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common.nix
      ../../desktop/desktop.nix
      ../../desktop/develop.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda"; # or "nodev" for efi only
    useOSProber = true;
  };

  boot.initrd.luks.devices.data.device = "/dev/disk/by-uuid/b0e23447-8c9b-4fb8-a782-244ecebfe18d";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b24869d1-f53a-45ff-baa9-451571402d28";
    fsType = "btrfs";
    options = [ "compress=lzo" ];
  };

  networking.hostName = "x230";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services.xserver.libinput.mouse.accelSpeed = "1.0";
}

