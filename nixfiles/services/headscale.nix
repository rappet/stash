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
      dns_config.nameservers = [
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
        "8.8.8.8"
        "8.8.4.4"
        "2001:4860:4860:0:0:0:0:8888"
        "2001:4860:4860:0:0:0:0:8844"
      ];
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
