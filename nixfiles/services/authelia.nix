{ config, pkgs, lib, ... }:

let
  domain = "sso.rappet.xyz";
  ports = import ./ports.nix;
in
rec {
  services.authelia.instances.rappet-xyz = {
    enable = true;
    settings = {
      theme = "auto";
      authentication_backend = { };
      access_control = {
        default_policy = "deny";
        # We want this rule to be low priority so it doesn't override the others
        rules = lib.mkAfter [
          {
            domain = "*.rappet.xyz";
            policy = "one_factor";
          }
        ];
      };
      storage.postgres = {
        address = "unix:///run/postgresql";
        database = "authelia";
        username = "authelia";
        # this should be ignored by postgresql
        password = "authelia";
      };
      session = {
        cookies = [
          {
            domain = "rappet.xyz";
            authelia_url = "https://sso.rappet.xyz";
            # The period of time the user can be inactive for before the session is destroyed
            inactivity = "1M";
            # The period of time before the cookie expires and the session is destroyed
            expiration = "3M";
            # The period of time before the cookie expires and the session is destroyed
            # when the remember me box is checked
            remember_me = "1y";
          }
        ];

      };
      server = {
        address = "tcp://:${toString ports.authelia-https}/";
        tls = {
          key = "/var/lib/acme/sso.rappet.xyz/key.pem";
          certificate = "/var/lib/acme/sso.rappet.xyz/fullchain.pem";
          client_certificates = [ ];
        };
      };
      log.level = "info";
    };

    # oidc clients
    settingsFiles = [ ];
    secrets = with config.age.secrets; {
      jwtSecretFile = authelia-jwt-secret.path;
      oidcIssuerPrivateKeyFile = authelia-jwks.path;
      oidcHmacSecretFile = authelia-hmac-secret.path;
      sessionSecretFile = authelia-session-secret.path;
      storageEncryptionKeyFile = authelia-storage-secret.path;
    };
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "authelia";
      ensureDBOwnership = true;
    }];
    ensureDatabases = [ "authelia" ];
  };

  users.groups.authelia-cert.members = [ "authelia" ];
  security.acme.certs."${domain}" = {
    group = "authelia-rappet-xyz";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = "${domain}";
  };

  age.secrets = builtins.listToAttrs (builtins.map
    (name: {
      name = "authelia-${name}";
      value = {
        file = ../secret/authelia-${name}.age;
        owner = "authelia-rappet-xyz";
        group = "authelia-rappet-xyz";
      };
    }) [ "hmac-secret" "jwks" "jwt-secret" "session-secret" "storage-secret" ]);
}
