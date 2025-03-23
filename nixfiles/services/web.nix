{ config, pkgs, system, ... }:
{
  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;

    clientMaxBodySize = "5G";

    virtualHosts = {
      "rappet.xyz" = {
        forceSSL = true;
        sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";

        locations."/" = {
          root = "/var/www/rappet.xyz";
        };
        locations."/share" = {
          # /var/www/share
          root = "/var/www";
        };
        locations."/public" = {
          # /var/www/public
          root = "/var/www";
          extraConfig = ''
            autoindex on;
          '';
        };
      };

    };
  };

  system.activationScripts.knot-acme-zones = ''
    cat ${./zones/_acme-challenge.rappet.xyz.zone} > /var/lib/knot/_acme-challenge.rappet.xyz.zone
  '';

  security.acme.certs."rappet.xyz" = {
    group = "nginx";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = "rappet.xyz";
    extraDomainNames = [ "*.rappet.xyz" ];
  };

  users.groups.web-share.members = [ "nginx" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "certbot@rappet.de";
  };

  age.secrets.letsencrypt-hetzner = {
    file = ../secret/letsencrypt-hetzner.age;
    owner = "root";
    group = "root";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
