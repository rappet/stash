{ config, pkgs, ... }:
{
  services.owncast = {
    enable = true;
    port = (import ../ports.nix).owncast-http;
    openFirewall = true;
  };

  services.nginx.virtualHosts."live.rappet.xyz" = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.owncast.port}";
    };
    extraConfig = ''
      access_log off;
    '';
  };
}
