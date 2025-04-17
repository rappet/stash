{ config, pkgs, ... }:

{
  services.mastodon = {
    enable = true;
    localDomain = "social.rappet.xyz";
    configureNginx = true;
    smtp.fromAddress = "noreply@social.example.com"; # Email address used by Mastodon to send emails, replace with your own
    extraConfig.SINGLE_USER_MODE = "true";
    streamingProcesses = 3;
  };

  services.nginx.virtualHosts.${config.services.mastodon.localDomain} = {
    enableACME = false;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
  };
}
