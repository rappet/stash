{ config, pkgs, ... }:

let
  ports = import ../ports.nix;
in
{
  services.qbittorrent = {
    enable = true;
    extraArgs = [
      "--confirm-legal-notice"
    ];
    webuiPort = ports.qbittorrent-http;
    torrentingPort = 51413;
  };

  services.nginx.virtualHosts."qbittorrent.rappet.xyz" = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.qbittorrent-http}";
      recommendedProxySettings = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 51413 ];
    allowedUDPPorts = [ 51413 ];
  };
}
