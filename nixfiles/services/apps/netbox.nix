{ config, pkgs, ... }:

let
  domain = "netbox.rappet.xyz";
  ports = import ../ports.nix;
in
rec {
  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    settings = {
      ALLOWES_HOSTS = [ domain ];
    };
    port = ports.netbox-http;
    secretKeyFile = "/var/lib/netbox/secret-key-file";
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
    locations = {
      "/" = {
        proxyPass = "http://[::1]:${toString config.services.netbox.port}";
      };
      "/static/" = {
        alias = "${config.services.netbox.dataDir}/static/";
      };
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
