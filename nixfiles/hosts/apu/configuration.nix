# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
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

  fileSystems."/mnt/extern" =
    { device = "/dev/mapper/sd_crypt";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" ];
    };
  fileSystems."/shared" =
    { device = "/dev/mapper/sd_crypt";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" "subvol=@public" ];
    };
  fileSystems."/smbhome" =
    { device = "/dev/mapper/sd_crypt";
      fsType = "btrfs";
      options = [ "noatime" "nodiratime" "subvol=@smbhome" ];
    };
  
  fileSystems."/media" =
    { device = "/dev/mapper/vg--data-media";
      fsType = "xfs";
      options = [ "noatime" "nodiratime" ];
    };

  networking.hostName = "apu"; # Define your hostname.

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

