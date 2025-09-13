{ config, pkgs, ... }:

let
  ports = import ../ports.nix;
in
{
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    openRPCPort = false;
    openPeerPorts = true;
    settings = {
      rpc-bind-address = "::";
      # yeah, good software
      #rpc-whitelist = "2a0e:46c6:0:200::1";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = true;
      download-dir = "/var/media/torrents";
      rpc-host-whitelist = "transmission.rappet.xyz";
      rpc-authentication-required = true;
    };
    credentialsFile = "${config.age.secrets.transmission.path}";
  };

  systemd.services.transmission.serviceConfig = {
    # bug with dual stack - I hate transmission
    RestrictAddressFamilies = "AF_UNIX AF_INET";
  };

  age.secrets.transmission = {
    file = ../../secret/transmission.age;
    owner = "transmission";
    group = "root";
  };

  services.nginx.virtualHosts."transmission.rappet.xyz" = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString ports.transmission}";
      recommendedProxySettings = true;
    };
  };
}
