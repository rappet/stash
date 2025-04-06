{ modulesPath, pkgs, inputs, system, config, ... }: {
  imports = [
    #./hardware-configuration.nix
    ../../common.nix
    ../../services/infrastructure/web.nix
    ../../services/infrastructure/postgresql-backup.nix
    ./backup.nix
    #../../services/apps/libreddit.nix
    #../../services/apps/mumble.nix
    ../../services/apps/headscale.nix
    ../../services/apps/quassel.nix
    ../../services/infrastructure/dns.nix
    ../../services/infrastructure/grafana.nix
    ../../services/infrastructure/prometheus.nix
    ../../services/infrastructure/loki.nix
    ../../services/infrastructure/unbound.nix
    #../../services/infrastructure/gitea.nix
    ../../services/apps/hedgedoc.nix
    #../../services/infrastructure/etesync.nix
    ../../services/apps/vaultwarden.nix
    ../../services/mosquitto.nix
    ../../services/apps/jellyfin.nix
    ../../services/smb-media.nix
    ../../services/apps/owncast.nix
    ../../services/infrastructure/kanidm.nix
    ../../services/apps/transmission.nix
    #../../services/infrastructure/authelia.nix


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

  systemd.services.rappet-xyz = {
    description = "";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "rappet-xyz";
      Group = "rappet-xyz";
      ExecStart = "${inputs.rappet-xyz.packages.${system}.rappet-xyz}/bin/rappet-xyz";
    };
  };

  users.users.rappet-xyz = {
    home = "/var/lib/rappet-xyz";
    useDefaultShell = true;
    group = "rappet-xyz";
    isSystemUser = true;
  };

  users.groups.rappet-xyz = { };


  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "2a0e:46c6:0:300::1" ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard-keys/private";
      mtu = 1432;

      peers = [
        # fra1-de
        {
          publicKey = "DxJmELlueuf/1YnlMA9FUuqI0GPPeF5yW1EMc5G8s1g=";
          allowedIPs = [ "2a0e:46c6::/40" ];
          persistentKeepalive = 25;
          endpoint = "193.148.249.188:51820";
        }
        {
          # thinkcentre
          publicKey = "xSG3PDLprnlUkPGCwAj7uTjxCmmR2M8M8cXsWBK1CVs=";
          allowedIPs = [ "2a0e:46c6:0:100::/60" ];
        }
        {
          # framework
          publicKey = "LbrjQAvVKt9MrcD+6NQ+3KcYCdtVw7RFblveaTB1xHA=";
          allowedIPs = [ "2a0e:46c6:0:200::/60" ];
        }
      ];
    };
  };

}
