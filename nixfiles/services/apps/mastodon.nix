{ config, pkgs, ... }:

let
  domain = "social.rappet.xyz";
in
{
  services.mastodon = {
    enable = true;
    localDomain = domain;
    configureNginx = true;
    smtp.fromAddress = "noreply@${domain}"; # Email address used by Mastodon to send emails, replace with your own
    extraConfig.SINGLE_USER_MODE = "true";
    streamingProcesses = 3;
    extraEnvFiles = [ config.age.secrets.mastodon-env.path ];
  };

  age.secrets.mastodon-env.file = ../../secret/mastodon-env.age;

  services.nginx.virtualHosts.${config.services.mastodon.localDomain} = {
    enableACME = false;
    sslCertificate = "/var/lib/acme/${domain}/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/${domain}/key.pem";
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
