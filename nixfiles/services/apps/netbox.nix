{ config, pkgs, ... }:

let
  domain = "netbox.rappet.xyz";
  ports = import ../ports.nix;
in
rec {
  services.netbox = {
    enable = true;
    settings = {
      ALLOWES_HOSTS = [ domain ];
    };
    port = ports.netbox-http;
    secretKeyFile = "/var/lib/netbox/secret-key-file";
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.netbox.port}";
    };
  };
}
