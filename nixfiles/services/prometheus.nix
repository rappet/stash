{ config, pkgs, ... }:

let
  domain = "prometheus.rappet.xyz";
  ports = import ./ports.nix;
in{
  services.prometheus = {
    enable = true;
    port = ports.prometheus;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = ports.prometheus-node-exporter;
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "services.rappet.xyz:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };

  #services.nginx.virtualHosts."${domain}" = {
  #  forceSSL = true;
  #  enableACME = true;
  #  locations."/" = {
  #    proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
  #    recommendedProxySettings = true;
  #  };
  #};


}
