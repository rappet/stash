{ config, pkgs, ... }:

let
  domain = "git.rappet.xyz";
  ports = import ./ports.nix;
in
rec {
  services.gitea = {
    enable = true;
    database = {
      type = "postgres";
      host = "/run/postgresql/";
    };
    settings.server = {
      HTTP_PORT = ports.gitea-http;
      ROOT_URL = "https://${domain}/";
      DOMAIN = domain;
      DISABLE_SSH = true;
    };
    settings.service = {
      DISABLE_REGISTRATION = true;
    };
    appName = "rappet's Gitea";
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "gitea";
      ensurePermissions = {
        "DATABASE gitea" = "ALL PRIVILEGES";
      };
    }];
    ensureDatabases = [ "gitea" ];
  };

  services.postgresqlBackup.databases = [ "gitea" ];

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.gitea.settings.server.HTTP_PORT}";
    };
  };
}
