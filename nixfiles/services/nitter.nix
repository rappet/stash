{ config, pkgs, ... }:
{
  services.nitter = {
    enable = true;
    server = {
      title = "nitter - rappet.xyz";
      # IPv6 does not work :/
      address = "127.0.0.1";
      port = 10001;
      hostname = "nitter.rappet.xyz";
    };
  };

  services.nginx.virtualHosts."nitter.rappet.xyz" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:10001";
    };
    extraConfig = ''
      access_log off;
    '';
  };
}
