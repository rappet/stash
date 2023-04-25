{ config, pkgs, ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "rappet.xyz" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/rappet.xyz";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "certbot@rappet.de";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
