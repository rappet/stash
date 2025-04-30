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
      # we want to update metadata!
      isReadOnly = false;
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
    sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
    locations."/" = {
      proxyPass = "http://${config.containers.jellyfin.localAddress}:8096";
    };
  };

  security.acme.certs."${domain}" = {
    group = "nginx";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = domain;
    extraDomainNames = [
      "${config.networking.hostName}.lb.rappet.xyz"
    ];
  };
}
