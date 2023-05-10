{ config, pkgs, blog, system, ... }:
{
  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "rappet.xyz" = {
        forceSSL = true;
        enableACME = true;
        root = "${blog.packages.${system}.blog}";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "certbot@rappet.de";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
