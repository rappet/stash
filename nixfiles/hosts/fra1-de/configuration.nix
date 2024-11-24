{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../services/dns.nix
  ];

  boot.tmp.cleanOnBoot = true;
  boot.loader.grub.device = "/dev/vda";
  zramSwap.enable = true;
  networking.hostName = "fra1-de";
  networking.domain = "bb.rappet.xyz";
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  networking.firewall.enable = false;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.interfaces = {
    lo = {
      ipv6.addresses = [{
        address = "2a0e:46c6::2";
        prefixLength = 128;
      }];
    };
    ens18 = {
      ipv4.addresses = [{
        address = "193.148.249.188";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "2a0c:9a40:1::609";
        prefixLength = 48;
      }];
    };
    # KleyReX
    ens19 = {
      ipv4.addresses = [{
        address = "193.189.82.213";
        prefixLength = 23;
      }];
      ipv6.addresses = [{
        address = "2001:7f8:33::a120:7968:1";
        prefixLength = 64;
      }];
    };
    # LocIX FRA
    ens20 = {
      ipv4.addresses = [{
        address = "185.1.166.140";
        prefixLength = 23;
      }];
      ipv6.addresses = [{
        address = "2001:7f8:f2:e1:0:a120:7968:1";
        prefixLength = 64;
      }];
    };
  };

  networking.defaultGateway = {
    address = "193.148.249.1";
    interface = "ens18";
  };

  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];



  services.bird2 = {
    enable = true;
    config = ''
      include "${./bird/prefix_lists/exportnet4.conf}";
      include "${./bird/prefix_lists/exportnet6.conf}";
  
      # common config
      ${builtins.readFile ./bird/common.conf}

      # IPv4 related config
      ${builtins.readFile ./bird/bird4.conf}

      # IPv6 related config
      ${builtins.readFile ./bird/bird6.conf}
    '';
  };

  services.birdwatcher = {
    enable = true;
    settings = ''
      ${builtins.readFile ./bird/birdwatcher.conf}

    [bird]
    listen = "0.0.0.0:29184"
    config = "/etc/bird/bird2.conf"
    birdc  = "${pkgs.bird}/bin/birdc"
    ttl = 5 # time to live (in minutes) for caching of cli output
    '';
  };

  services.prometheus.exporters.bird = {
    enable = true;
    # what firewall?
    # openFirewall = true;
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "2a0e:46c6:0:1::1" ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard-keys/private";
      mtu = 1432;

      peers = [
        {
          # thinkcentre
          publicKey = "Q03DQgQvETlzyg/r2ICzBjLHzfX9Z76SDentriesEE0=";
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
