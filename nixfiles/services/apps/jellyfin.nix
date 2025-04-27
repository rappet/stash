{
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = "jellyfin.rappet.xyz";
  ports = import ../ports.nix;
in
rec {
  containers.jellyfin = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    bindMounts.media = {
      mountPoint = "/media";
      hostPath = "/var/media";
    };

    config =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        environment.systemPackages = [
          pkgs.jellyfin
          pkgs.jellyfin-web
          pkgs.jellyfin-ffmpeg
        ];

        services.jellyfin = {
          enable = true;
          openFirewall = true;
          #proxyPass = "http://127.0.0.1:8096";
        };

        system.stateVersion = "23.05";

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 80 ];
          };
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
      };
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://${config.containers.jellyfin.localAddress}:8096";
    };
  };
}
