{ config, pkgs, ... }:

let
  domain = "vaultwarden.rappet.xyz";
  ports = import ../ports.nix;
in
rec {
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_PORT = ports.vaultwarden-http;
    };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}";
    };
  };
}
