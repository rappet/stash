{ modulesPath, pkgs, inputs, system, config, ... }: {
  imports = [
    #./hardware-configuration.nix
    ../../common.nix
    ../../services/infrastructure/web.nix
    ../../services/infrastructure/postgresql-backup.nix
    #./backup.nix

    (modulesPath + "/installer/scan/not-detected.nix")
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
    hostName = "thinkcentre";
    domain = "rappet.xyz";
    hostId = "c1037a3f";
    extraHosts = "91.99.19.52 ns1.rappet.xyz";
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "eno1";
      enableIPv6 = true;
    };
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
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

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };


  networking.wireguard = {
      enable = true;
      interfaces.wg0 = {
        ips = [ "2a0e:46c6:0:100::1" ];
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
            # framework
            publicKey = "LbrjQAvVKt9MrcD+6NQ+3KcYCdtVw7RFblveaTB1xHA=";
            allowedIPs = [ "2a0e:46c6:0:200::/60" ];
          }
        ];
      };
    };
}
