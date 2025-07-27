{
  config,
  pkgs,
  system,
  inputs,
  ...
}:
{
  services.garage = {
    enable = true;
    package = pkgs.garage_1;
    settings = {
      db_engine = "sqlite";
      replication_factor = 3;
      rpc_bind_addr = "[::]:3901";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.eimer.rappet.xyz";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.eimer.rappet.xyz";
        index = "index.html";
      };
      k2v_api = {
        api_bind_addr = "[::]:3904";
      };
      admin = {
        api_bind_addr = "[::]:3903";
      };
    };
    environmentFile = config.age.secrets.garage-env.path;
  };

  networking.firewall = {
    allowedTCPPorts = [
      3901
      3903
    ];
  };

  age.secrets.garage-env = {
    file = ../../secret/garage-env.age;
    owner = "root";
    group = "root";
  };

  services.nginx = {
    clientMaxBodySize = "5G";

    virtualHosts = {
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

  security.acme.certs."eimer.rappet.xyz" = {
    group = "loadbalancer";
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
}
