{
  modulesPath,
  pkgs,
  inputs,
  system,
  config,
  ...
}:
{
  imports = [
    ../../common.nix
    ../../services/infrastructure/loadbalancer.nix
    ../../services/infrastructure/garage.nix
    ../../services/infrastructure/web.nix
    #../../services/infrastructure/postgresql-backup.nix
    ../../services/infrastructure/dns.nix
    ../../services/infrastructure/unbound.nix

    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    #../../wg-mesh.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostName = "ams1-nl";
    domain = "rappet.xyz";
    hostId = "85337bbb";
    interfaces.enp7s0.ipv6.addresses = [
      {
        address = "2a0a:4cc0:40:203d::";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp7s0";
    };
    extraHosts = "91.99.19.52 ns1.rappet.xyz";
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp7s0";
      enableIPv6 = true;
    };
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  services.zfs = {
    autoScrub.enable = true;
  };

  # 2GB ARC cache max
  boot.kernelParams = [ "zfs.zfs_arc_max=2147483648" ];

  services.sanoid = {
    enable = true;

    datasets = {
      "zroot/root" = {
        use_template = [ "data" ];
      };
    };

    templates.data = {
      frequently = 0;
      hourly = 36;
      daily = 0;
      monthly = 0;
      yearly = 0;
      autosnap = true;
      autoprune = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
