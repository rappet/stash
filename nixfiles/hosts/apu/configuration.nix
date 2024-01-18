{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../services/mdns.nix
    ../../services/samba.nix
    #../../services/hass.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  environment.etc."crypttab".text = ''
    intern       UUID=16e5afc0-6b57-4376-bc0d-b0aa389f3621 /root/internkey      luks,discard
    extflashlvm  UUID=fdca7cbc-9423-4ec6-becd-8b7087954be2 /root/externflashkey luks,discard
  '';

  fileSystems = {
    "/var/btrfs_intern" = {
      device = "/dev/mapper/intern";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" ];
    };
    "/var/shared" = {
      device = "/dev/mapper/intern";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" "subvol=@shared" ];
    };
    "/var/smbhome" = {
      device = "/dev/mapper/intern";
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
