{ config, pkgs, ... }:

let
  domain = "git.rappet.xyz";
  ports = import ./ports.nix;
in
rec {
  services.forgejo = {
    enable = true;
    settings.server = {
      HTTP_PORT = ports.gitea-http;
      ROOT_URL = "https://${domain}/";
      DOMAIN = domain;
      DISABLE_SSH = false;
    };
    settings.service = {
      DISABLE_REGISTRATION = true;
    };
    settings.DEFAULT.APP_NAME = "rappet's Forge";
  };

  networking.firewall.allowedTCPPorts = [ 22 9000 ];

  containers.woodpecker = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.101.10";
    localAddress = "192.168.101.12";
    hostAddress6 = "fc01::1";
    localAddress6 = "fc01::2";
    forwardPorts = [{
      containerPort = 9000;
      hostPort = 9000;
      protocol = "tcp";
    }];

    bindMounts."${config.age.secrets.woodpecker-env.path}".isReadOnly = true;

    config = { config, pkgs, lib, ... }: {
      services.woodpecker-server = {
        enable = true;
        environment = {
          WOODPECKER_HOST = "https://ci.rappet.xyz";
          WOODPECKER_OPEN = "true";
          WOODPECKER_SERVER_ADDR = ":8080";
        };
        environmentFile = "/run/agenix/woodpecker-env";
      };

      #services.woodpecker-agents.agents."docker" = {
      #  enable = true;
      #  # We need this to talk to the podman socket
      #  extraGroups = [ "podman" ];
      #  environment = {
      #    WOODPECKER_SERVER = "localhost:9000";
      #    WOODPECKER_MAX_WORKFLOWS = "4";
      #    DOCKER_HOST = "unix:///run/podman/podman.sock";
      #    WOODPECKER_BACKEND = "docker";
      #  };
      #  # Same as with woodpecker-server
      #  environmentFile = [ "/run/agenix/woodpecker-env" ];
      #};

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 8080 9000 ];
      };
      networking.useHostResolvConf = lib.mkForce false;

      #virtualisation.podman = {
      #  enable = true;
      #  dockerCompat = true;
      #  defaultNetwork.settings = {
      #    dns_enabled = true;
      #  };
      #};

      system.stateVersion = "23.05";
      services.resolved.enable = true;
    };
  };

  age.secrets.woodpecker-env = {
    file = ../secret/woodpecker-env.age;
    owner = "root";
    group = "root";
  };

  services.nginx.virtualHosts.${domain} = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      proxyPass = "http://[::1]:${toString config.services.forgejo.settings.server.HTTP_PORT}";
    };
  };

  services.nginx.virtualHosts."ci.rappet.xyz" = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
    locations."/" = {
      #proxyPass = "http://[::1]:${toString ports.woodpecker-http}";
      proxyPass = "http://${config.containers.woodpecker.localAddress}:8080";
    };
  };
}
