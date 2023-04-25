{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../services/mdns.nix
    ../../services/samba.nix
    ../../services/hass.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  environment.etc."crypttab".text = ''
    sd_crypt   UUID=dbd1e699-0eaf-4327-b773-e281a81e12e7 /root/sdkey     luks,discard
    extflashlvm     UUID=fdca7cbc-9423-4ec6-becd-8b7087954be2       /root/externflashkey    luks,discard
  '';

  fileSystems = {
    "/mnt/extern" = {
      device = "/dev/mapper/sd_crypt";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" ];
    };
    "/shared" = {
      device = "/dev/mapper/sd_crypt";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" "subvol=@public" ];
    };
    "/smbhome" = {
      device = "/dev/mapper/sd_crypt";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" "subvol=@smbhome" ];
    };

    "/media" = {
      device = "/dev/mapper/vg--data-media";
      fsType = "xfs";
      options = [ "noatime" "nodiratime" ];
    };
  };

  networking.hostName = "apu";
}
