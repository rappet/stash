{ pkgs, ... }:

let
  domain = "mumble.rappet.xyz";
in
{
  services.murmur = {
    enable = true;
    openFirewall = true;
    welcometext = "Hello, please as rappet if you want to use this server!";
    registerName = "${domain}";
    bandwidth = 300000;
    sslKey = "/var/lib/acme/${domain}/key.pem";
    sslCert = "/var/lib/acme/${domain}/cert.pem";
  };


  users.users.nginx.extraGroups = [ "murmur" ];
  security.acme.certs."${domain}".group = "murmur";

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    enableACME = true;
  };
}
