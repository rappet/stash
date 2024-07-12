{ config, pkgs, blog, system, ... }:
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
        root = "${blog.packages.${system}.blog}";

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
    dnsProvider = "rfc2136";
    credentialsFile = "${pkgs.writeText "rfc2136" ''
      RFC2136_NAMESERVER=127.0.0.1
    ''}";
    domain = "rappet.xyz";
    extraDomainNames = [ "*.rappet.xyz" ];
  };

  users.groups.web-share.members = [ "nginx" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "certbot@rappet.de";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
