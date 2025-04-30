{ config, pkgs, ... }:

let
  domain = "md.rappet.xyz";
  ports = import ../ports.nix;
in
rec {
  services.hedgedoc = {
    enable = true;
    settings = {
      port = ports.hedgedoc-http;
      host = "::1";
      domain = domain;
      protocolUseSSL = true;

      allowAnonymous = true;
      allowAnonymousEdits = true;
      allowEmailRegister = false;
      allowFreeURL = true;

      db = {
        dialect = "postgres";
        host = "/var/run/postgresql";
      };

      oauth2 = {
        tokenURL = "https://git.rappet.xyz/login/oauth/access_token";
        scope = "read:user";
        #rolesClaim = "";
        providerName = "Gitea";
        baseURL = "https://git.rappet.xyz/login/oauth/";
        authorizationURL = "https://git.rappet.xyz/login/oauth/authorize";
        userProfileURL = "https://git.rappet.xyz/login/oauth/userinfo";
        userProfileEmailAttr = "email";
        userProfileUsernameAttr = "name";
        userProfileDisplayNameAttr = "preferred_username";
        clientID = "$OAUTH2_CLIENT_ID";
        clientSecret = "$OAUTH2_CLIENT_SECRET";
      };
      sessionSecret = " $SESSION_SECRET";
    };
    environmentFile = config.age.secrets.hedgedoc-env.path;
  };

  age.secrets.hedgedoc-env = {
    file = ../../secret/hedgedoc-env.age;
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "hedgedoc";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "hedgedoc" ];
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.hedgedoc.settings.port}";
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
