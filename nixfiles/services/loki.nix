{ pkgs, config, ... }:

let
  ports = import ./ports.nix;
in
{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = ports.loki_http;
        #grpc_listen_port = ports.grpc_http;
      };

      common = {
        instance_addr = "127.0.0.1";
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = "/tmp/loki";
      };

      schema_config.configs = [{
        from = "2023-05-09";
        store = "boltdb-shipper";
        object_store = "filesystem";
        schema = "v11";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = ports.promtail_http;
        grpc_listen_port = 0;
      };
      positions.filename = "/tmp/positions.yml";
      clients = [{
        url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
      }];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [{
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }];
        }
      ];
    };
  };
}
