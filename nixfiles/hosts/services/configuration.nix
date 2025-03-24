{ modulesPath, pkgs, ... }: {
  imports = [
    #./hardware-configuration.nix
    ../../common.nix
    ../../services/web.nix
    ../../services/postgresql-backup.nix
    #../../services/libreddit.nix
    #../../services/mumble.nix
    ../../services/headscale.nix
    ../../services/quassel.nix
    ../../services/dns.nix
    ../../services/grafana.nix
    ../../services/prometheus.nix
    ../../services/loki.nix
    #../../services/gitea.nix
    ../../services/hedgedoc.nix
    #../../services/etesync.nix
    ../../services/vaultwarden.nix
    ../../services/mosquitto.nix
    ../../services/jellyfin.nix
    ../../services/smb-media.nix
    ../../services/owncast.nix
    ../../services/kanidm.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
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
    hostName = "services";
    domain = "rappet.xyz";
    hostId = "85337bbb";
    interfaces.enp1s0.ipv6.addresses = [{
      address = "2a01:4f8:1c1a:a55::1";
      prefixLength = 128;
    }];
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
    extraHosts = "91.99.19.52 ns1.rappet.xyz";
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp1s0";
      enableIPv6 = true;
    };
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
  };

  users.users.apple-upload = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlnhuyIavKvmi+F6vXQugaAmYZ6/R0rsuu7Bilhbpt9 Kurzbefehle auf rappets iPhone"
    ];
    extraGroups = [ "web-share" ];
  };

  services.zfs = {
    autoScrub.enable = true;
  };

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
      daily = 30;
      monthly = 3;
      yearly = 0;
      autosnap = true;
      autoprune = true;
    };
  };
}
