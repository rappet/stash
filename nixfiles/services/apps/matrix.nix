{ config, pkgs, ... }:
let
  domain = "rappet.xyz";
in
{
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = domain;
        allow_registration = true;
        allow_encryption = true;
        allow_federation = true;
        trusted_servers = [ "matrix.org" ];
        address = null; # Must be null when using unix_socket_path
        unix_socket_path = "/run/continuwuity/continuwuity.sock";
        unix_socket_perms = 666; # Default permissions for the socket
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8448 ];
  users.users.nginx.extraGroups = [ "continuwuity" ];

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
      proxyPass = "http://unix:${toString config.services.matrix-continuwuity.settings.global.unix_socket_path}";
    };
  };
}
