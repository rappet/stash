# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, system, ... }:

{
  imports = [
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
    efiSupport = true;
    device = "nodev"; # or "nodev" for efi only
    useOSProber = true;
    fontSize = 16;
  };

  boot.initrd.luks.devices.data.device = "/dev/disk/by-uuid/46206b09-7818-46f6-a205-1feea36bdb1e";

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/477eddca-bb72-4150-8391-534cb023b387";
    fsType = "xfs";
    options = [ "defaults" ];
  };

  boot.loader.grub.extraEntries = ''
    menuentry "Ubuntu" {
      insmod part_gpt
      insmod ext2
      search --no-floppy --fs-uuid --set root f36c6ba4-e459-4bc5-b147-89cfd833561d
      linux //vmlinuz-5.19.0-35-generic quiet splash cryptdevice=UUID=46206b09-7818-46f6-a205-1feea36bdb1e root=/dev/mapper/vgubuntu-root
      initrd //initrd.img-5.19.0-35-generic
    }
  '';

  networking.hostName = "katze";

  # Thanks Microsoft
  time.hardwareClockInLocalTime = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
}

