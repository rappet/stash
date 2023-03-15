# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common.nix
      ../../desktop/desktop.nix
      ../../desktop/develop.nix
      ../../desktop/gaming.nix
    ];

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    # efiInstallAsRemovable = true;
    # Define on which hard drive you want to install Grub.
    device = "nodev"; # or "nodev" for efi only
    useOSProber = true;
    fontSize = 16;
  };

  boot.plymouth.enable = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "quiet" ];


  networking.hostName = "katze"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/477eddca-bb72-4150-8391-534cb023b387";
      fsType = "xfs";
      options = [ "defaults" ];
    };

  # Thanks Microsoft
  time.hardwareClockInLocalTime = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;


  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  boot.initrd.luks.devices.data.device = "/dev/disk/by-uuid/46206b09-7818-46f6-a205-1feea36bdb1e";

  # nixos-config=/home/rappet/stash/nixfiles/home/katze/configuration.nix;
}

