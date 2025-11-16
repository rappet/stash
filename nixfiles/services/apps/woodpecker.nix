{ config, pkgs, ... }:

let
  domain = "ci.rappet.xyz";
  ports = import ../ports.nix;
in
rec {
  services.woodpecker-server = {
    enable = true;
    environment = {
      WOODPECKER_OPEN = "true";
      WOODPECKER_ADMIN = "rappet";
      WOODPECKER_HOST = "https://${domain}";
      WOODPECKER_SERVER_ADDR = ":${toString ports.woodpecker-http}";
      WOODPECKER_PLUGINS_PRIVILEGED = "woodpeckerci/plugin-docker-buildx";
    };
    environmentFile = config.age.secrets.woodpecker-env.path;
  };

  networking.firewall.allowedTCPPorts = [ 9000 ];

  age.secrets.woodpecker-env = {
    file = ../../secret/woodpecker-env.age;
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
    locations."/" = {
      proxyPass = "http://[::1]:${toString ports.woodpecker-http}";
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
