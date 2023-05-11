{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../services/web.nix
    ../../services/postgresql-backup.nix
    ../../services/nitter.nix
    ../../services/libreddit.nix
    ../../services/mumble.nix
    ../../services/headscale.nix
    ../../services/quassel.nix
    ../../services/dns-nsd.nix
    ../../services/grafana.nix
    ../../services/prometheus.nix
    ../../services/loki.nix
    ../../services/gitea.nix
    ../../services/hedgedoc.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "services";
  networking.domain = "rappet.xyz";
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  networking = {
    interfaces.enp1s0.ipv6.addresses = [{
      address = "2a01:4f8:c012:b412::1";
      prefixLength = 64;
    }];
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
    extraHosts = "167.235.255.49 ns1.rappet.xyz";
  };
}