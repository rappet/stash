{ config, pkgs, ... }:

let domain = "headscale.rappet.xyz";
in
{
  services.headscale = {
    enable = true;
    address = "[::]";
    port = 10003;
    settings = {
      logtail.enabled = false;
      server_url = "https://${domain}";
      dns_config.baseDomain = "hn.rappet.xyz";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass =
        "http://localhost:${toString config.services.headscale.port}";
      proxyWebsockets = true;
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];
}
