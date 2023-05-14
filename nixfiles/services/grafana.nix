{ config, pkgs, ... }:

let
  domain = "grafana.rappet.xyz";
  ports = import ./ports.nix;
in
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = domain;
      http_port = ports.grafana;
      http_addr = "[::1]";
    };
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        url = "http://[::1]:${toString ports.prometheus}";
        type = "prometheus";
      }
      {
        name = "Loki";
        url = "http://[::1]:${toString config.services.loki.configuration.server.http_listen_port}";
        type = "loki";
      }
    ];
  };

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.grafana.settings.server.http_port}";
      recommendedProxySettings = true;
    };
  };
}
