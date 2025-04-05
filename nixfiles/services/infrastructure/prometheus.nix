{ config, pkgs, ... }:

let
  domain = "prometheus.rappet.xyz";
  ports = import ../ports.nix;
in
{
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
      {
        job_name = "bird";
        static_configs = [{
          targets = [ "193.148.249.188:9324" ];
          labels.host = "fra1-de";
        }];
      }
      {
        job_name = "haproxy";
        static_configs = [{
          targets = [ "services.rappet.xyz:${toString ports.haproxy-metrics-http}" ];
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
