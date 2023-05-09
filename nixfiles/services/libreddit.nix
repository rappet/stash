{ config, pkgs, ... }:
{
  services.libreddit = {
    enable = true;
    address = "127.0.0.1";
    port = (import ./ports.nix).libreddit;
  };

  services.nginx.virtualHosts."libreddit.rappet.xyz" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.libreddit.port}";
    };
    extraConfig = ''
      access_log off;
    '';
    basicAuthFile = config.age.secrets.libreddit-auth.path;
  };

  age.secrets.libreddit-auth = {
    file = ../secret/libreddit-auth.age;
    owner = "nginx";
    group = "nginx";
  };
}
