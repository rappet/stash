{ config, pkgs, lib, ... }:

let
  domain = "jellyfin.rappet.xyz";
  ports = import ./ports.nix;
in
  rec {
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    autoPrune = {
      enable = true;
      dates = "daily";
      flags = [ "--all" ];
    };
  #  defaultNetwork.settings.dns_enabled = true;
  };

  networking.firewall = {
    trustedInterfaces = [ "podman0" ];
    interfaces."podman+".allowedUDPPorts = [ 53 ];
    interfaces."podman+".allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  services.resolved.enable = true;

  virtualisation.oci-containers.containers.jellyfin = {
    image = "docker.io/jellyfin/jellyfin:latest";
    autoStart = true;
    ports = ["127.0.0.1:8096:8096"];
    volumes = [
      "jellyfin-config:/config"
      "jellyfin-cache:/cache"
      "/var/media:/media"
    ];
    extraOptions = [ "--network=host" ];
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      #proxyPass = "http://${config.containers.jellyfin.localAddress}:8096";
      proxyPass = "http://127.0.0.1:8096";
    };
  };
}
