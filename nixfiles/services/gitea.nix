{ config, pkgs, ... }:

let
  domain = "git.rappet.xyz";
  ports = import ./ports.nix;
in
rec {
  services.gitea = {
    enable = true;
    package = pkgs.forgejo;
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
      ensureDBOwnership = true;
    }];
    ensureDatabases = [ "gitea" ];
  };

  services.postgresqlBackup.databases = [ "gitea" ];

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.gitea.settings.server.HTTP_PORT}";
    };
  };
}
