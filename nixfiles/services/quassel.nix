{ config, pkgs, ... }:

let
  domain = "quassel.rappet.xyz";
in rec {
  services.quassel = {
    enable = true;
    requireSSL = true;
    certificateFile = "/var/lib/acme/${domain}/full.pem";
    interfaces = [ "0.0.0.0" ];
  };
  networking.firewall.allowedTCPPorts = [ config.services.quassel.portNumber ];

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "quassel";
      ensurePermissions = {
        "DATABASE quassel" = "ALL PRIVILEGES";
      };
    }];
    ensureDatabases = [ "quassel" ];
  };

  users.groups.quassel-cert.members = [ "quassel" "nginx" ];
  security.acme.certs."${domain}".group = "quassel-cert";

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
  };
}
