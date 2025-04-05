{ pkgs, config, ... }:

let
  ports = import ../ports.nix;
in
{
  services.unbound = {
    enable = true;
    package = pkgs.unbound-full;
    resolveLocalQueries = false;
    settings = {
      server = {
        access-control = [ "::/0 allow" "0.0.0.0/0 allow" ];
        # DoT, DoT, DoHTTPS
        interface = [ "0.0.0.0@853" "::@853" "::@${toString ports.unbound-https}" ];
        https-port = ports.unbound-https;
        tls-service-key = "${config.security.acme.certs."dns.rappet.xyz".directory}/key.pem";
        tls-service-pem = "${config.security.acme.certs."dns.rappet.xyz".directory}/fullchain.pem";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 853 ];

  security.acme.certs."dns.rappet.xyz" = {
    group = "unbound";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = "dns.rappet.xyz";
  };
}
