{ config, pkgs, ... }:

let
  ports = import ./ports.nix;
in
{
  services.kanidm = {
    enableServer = true;
    package = pkgs.kanidm_1_5;

    serverSettings = {
      bindaddress = "[::]:${toString ports.kanidm-https}";
      tls_chain = "/var/lib/acme/idm.rappet.xyz/fullchain.pem";
      tls_key = "/var/lib/acme/idm.rappet.xyz/key.pem";
      domain = "idm.rappet.xyz";
      origin = "https://idm.rappet.xyz";
    };
  };

  services.nginx.virtualHosts."idm.rappet.xyz" = {
      forceSSL = true;
      sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
      locations."/" = {
        #proxyPass = "http://[::1]:${toString ports.woodpecker-http}";
        proxyPass = "https://idm.rappet.xyz:${toString ports.kanidm-https}";
      };
    };

  security.acme.certs."idm.rappet.xyz" = {
      group = "kanidm";
      dnsProvider = "hetzner";
      credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
      domain = "idm.rappet.xyz";
    };
}
