{ modulesPath, pkgs, inputs, system, config, ... }: {
  imports = [
    #./hardware-configuration.nix
    ../../common.nix
    ../../services/infrastructure/web.nix
    ../../services/infrastructure/postgresql-backup.nix
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
    ../../services/apps/mastodon.nix


    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../wg-mesh.nix
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

  services.nginx.virtualHosts."rappet-xyz".locations."/pkg" = {
    root = "${inputs.rappet-xyz.packages.${system}.rappet-xyz}/bin/site";
  };

  users.users.rappet-xyz = {
    home = "/var/lib/rappet-xyz";
    useDefaultShell = true;
    group = "rappet-xyz";
    isSystemUser = true;
  };

  users.groups.rappet-xyz = { };

  nixpkgs.config.allowUnfree = true;

  services.minecraft-server = {
    enable = true;
    package = pkgs.papermcServers.papermc-1_21_4;
    eula = true;
    declarative = true;
    serverProperties = {
      server-port = 25565;
      difficulty = 3;
      gamemode = 1;
      max-players = 5;
      motd = "rappet's survival server";
      white-list = true;
      level-name = "Survival";
      view-distance = 16;
    };
    openFirewall = true;
    whitelist = {
      rappet = "588377a5-362f-4ea1-8195-9cf97dd7a884";
    };
  };
}
