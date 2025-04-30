{ config, pkgs, ... }:

let
  domain = "grafana.rappet.xyz";
  ports = import ../ports.nix;
in
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = domain;
      http_port = ports.grafana;
      http_addr = "127.0.0.1";
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
    sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      recommendedProxySettings = true;
    };
  };

  security.acme.certs."${domain}" = {
    group = "nginx";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = domain;
    extraDomainNames = [
      "${config.networking.hostName}.lb.rappet.xyz"
    ];
  };
}
