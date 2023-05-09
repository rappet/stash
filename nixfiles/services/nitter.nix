{ config, pkgs, ... }:
{
  services.nitter = {
    enable = true;
    server = {
      title = "nitter - rappet.xyz";
      # IPv6 does not work :/
      address = "127.0.0.1";
      port = (import ./ports.nix).nitter;
      hostname = "nitter.rappet.xyz";
    };
  };

  services.nginx.virtualHosts."nitter.rappet.xyz" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.nitter.server.port}";
    };
    extraConfig = ''
      access_log off;
    '';
    basicAuthFile = config.age.secrets.nitter-auth.path;
  };

  age.secrets.nitter-auth = {
    file = ../secret/nitter-auth.age;
    owner = "nginx";
    group = "nginx";
  };
}
