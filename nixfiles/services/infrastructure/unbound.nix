{ pkgs, config, ... }:

let
  ports = import ../ports.nix;
in
{
  services.unbound = {
    enable = true;
    package = pkgs.unbound-full;
    resolveLocalQueries = false;
    settings = {
      server = {
        access-control = [
          "::/0 allow"
          "0.0.0.0/0 allow"
        ];
        # DoT, DoT, DoHTTPS
        interface = [
          "0.0.0.0@853"
          "::@853"
          "::@${toString ports.unbound-https}"
        ];
        https-port = ports.unbound-https;
        tls-service-key = "${config.security.acme.certs."dns.rappet.xyz".directory}/key.pem";
        tls-service-pem = "${config.security.acme.certs."dns.rappet.xyz".directory}/fullchain.pem";

        extended-statistics = "yes";
      };
    };

    localControlSocketPath = "/run/unbound/unbound.socket";
  };

  networking.firewall.allowedTCPPorts = [ 853 ];

  security.acme.certs."dns.rappet.xyz" = {
    group = "unbound";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = "dns.rappet.xyz";
  };

  services.prometheus.exporters.unbound = {
    enable = true;
    port = ports.unbound-metrics;
    unbound = {
      host = "unix:///run/unbound/unbound.socket";
      certificate = null;
      ca = null;
      key = null;
    };
  };

  users.groups.prometheus.members = [ config.services.prometheus.exporters.unbound.user ];

  services.prometheus.scrapeConfigs = [
    {
      job_name = "unbound";
      static_configs = [
        {
          targets = [ "services.rappet.xyz:${toString ports.unbound-metrics}" ];
        }
      ];
    }
  ];
}
