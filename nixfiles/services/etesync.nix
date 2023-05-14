{ config, pkgs, ... }:

let
  domain = "sync.rappet.xyz";
  ports = import ./ports.nix;
in
rec {
  services.etebase-server = {
    enable = true;
    port = ports.etebase-http;
    settings.allowed_hosts.allowed_host1 = "sync.rappet.xyz";
    settings.global.secret_file = config.age.secrets.etebase-django-secret.path;
  };

  age.secrets.etebase-django-secret = {
    file = ../secret/etebase-django-secret.age;
    owner = "etebase-server";
    group = "etebase-server";
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.etebase-server.port}";
    };
  };
}
