{ config, pkgs, ... }:

let domain = "headscale.rappet.xyz";
in
{
  services.headscale = {
    enable = true;
    address = "[::]";
    port = (import ./ports.nix).headscale;
    settings = {
      logtail.enabled = false;
      server_url = "https://${domain}";
      dns_config.baseDomain = "hn.rappet.xyz";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass =
        "http://localhost:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];
}
