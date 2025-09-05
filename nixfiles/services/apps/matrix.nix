{ config, pkgs, ... }:
let
  domain = "rappet.xyz";
in
{
  services.matrix-tuwunel = {
    enable = true;
    settings = {
      global = {
        server_name = domain;
        allow_registration = true;
        allow_encryption = true;
        allow_federation = true;
        trusted_servers = [ "matrix.org" ];
        address = null; # Must be null when using unix_socket_path
        unix_socket_path = "/run/tuwunel/continuwuity.sock";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8448 ];
  users.users.nginx.extraGroups = [ "tuwunel" ];

  services.nginx.virtualHosts.${domain} = {
    listen = [
      {
        addr = "0.0.0.0";
        port = 8443;
        ssl = true;
      }
      {
        addr = "[::0]";
        port = 8443;
        ssl = true;
      }
      {
        addr = "[::0]";
        port = 8448;
        ssl = true;
      }
    ];
    forceSSL = true;
    sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
    locations."/_matrix/" = {
      proxyPass = "http://unix:${toString config.services.matrix-tuwunel.settings.global.unix_socket_path}";
    };
  };
}
