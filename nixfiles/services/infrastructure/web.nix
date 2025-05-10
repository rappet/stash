{
  config,
  pkgs,
  system,
  inputs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.tlslb
  ];

  services.haproxy = {
    enable = true;
    config = builtins.readFile ./haproxy.conf;
  };

  reverse-proxy = {
    enable = true;
    sniProxy.enabled = true;
  };

  services.nginx = {
    clientMaxBodySize = "5G";

    virtualHosts = {
      "rappet.xyz" = {
        forceSSL = true;
        sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
        default = true;

        locations."/" = {
          proxyPass = "http://localhost:3000";
        };
        #locations."/" = {
        #  root = "/var/www/rappet.xyz";
        #};
        locations."/share" = {
          # /var/www/share
          root = "/var/www";
        };
        locations."/public" = {
          # /var/www/public
          root = "/var/www";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
      "phanpy.rappet.xyz" = {
        forceSSL = true;
        sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";

        locations."/" = {
          root = "/var/www/phanpy.rappet.xyz";
        };
      };
      "s3.eimer.rappet.xyz" = {
        forceSSL = true;
        serverAliases = [
          "s3.eimer.rappet.xyz"
          "*.s3.eimer.rappet.xyz"
        ];
        sslCertificate = "/var/lib/acme/eimer.rappet.xyz/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/eimer.rappet.xyz/key.pem";
        locations."/" = {
          proxyPass = "http://[::1]:3900";
        };
      };
      "web.eimer.rappet.xyz" = {
        forceSSL = true;
        serverAliases = [ "*.web.eimer.rappet.xyz" ];
        sslCertificate = "/var/lib/acme/eimer.rappet.xyz/fullchain.pem";
        sslCertificateKey = "/var/lib/acme/eimer.rappet.xyz/key.pem";
        locations."/" = {
          proxyPass = "http://[::1]:3902";
        };
      };
    };
  };

  security.acme.certs."rappet.xyz" = {
    group = "nginx";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = "rappet.xyz";
    extraDomainNames = [
      "hn.rappet.xyz"
      "sync.rappet.xyz"
      "git.rappet.xyz"
      "ci.rappet.xyz"
      "registry.rappet.xyz"
      "live.rappet.xyz"
      "maps.rappet.xyz"
      "mc.rappet.xyz"
      "vaultwarden.rappet.xyz"
      "phanpy.rappet.xyz"
      "${config.networking.hostName}.lb.rappet.xyz"
    ];
  };

  security.acme.certs."eimer.rappet.xyz" = {
    group = "nginx";
    dnsProvider = "hetzner";
    credentialsFile = "${config.age.secrets.letsencrypt-hetzner.path}";
    domain = "eimer.rappet.xyz";
    extraDomainNames = [
      "s3.eimer.rappet.xyz"
      "*.s3.eimer.rappet.xyz"
      "*.web.eimer.rappet.xyz"
      "tools.rappet.xyz"
      "${config.networking.hostName}.rappet.xyz"
    ];
  };

  users.groups.web-share.members = [ "nginx" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "certbot@rappet.de";
  };

  age.secrets.letsencrypt-hetzner = {
    file = ../../secret/letsencrypt-hetzner.age;
    owner = "root";
    group = "root";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
