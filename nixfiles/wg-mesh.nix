{ config, ... }:

let
  hosts = [
    {
      name = "fra1-de";
      ip = "2a0e:46c6:0:1::1";
      publicKey = "DxJmELlueuf/1YnlMA9FUuqI0GPPeF5yW1EMc5G8s1g=";
      allowedIPs = [ "2a0e:46c6:0:1::/60" ];
      endpoint = "193.148.249.188:51820";
    }
    {
      name = "thinkcentre";
      ip = "2a0e:46c6:0:100::1";
      publicKey = "xSG3PDLprnlUkPGCwAj7uTjxCmmR2M8M8cXsWBK1CVs=";
      allowedIPs = [ "2a0e:46c6:0:100::/60" ];
      endpoint = null;
    }
    {
      name = "framework";
      ip = "2a0e:46c6:0:200::1";
      publicKey = "LbrjQAvVKt9MrcD+6NQ+3KcYCdtVw7RFblveaTB1xHA=";
      allowedIPs = [ "2a0e:46c6:0:200::/60" ];
      endpoint = null;
    }
    {
      name = "services";
      ip = "2a0e:46c6:0:300::1";
      publicKey = "G+dlubY61jRxl/E4f9xfBeD4gO3E47084XxDV3Hhl2g=";
      allowedIPs = [ "2a0e:46c6:0:300::/60" ];
      endpoint = "91.99.19.52:51820";
    }
  ];
  self = (builtins.listToAttrs (builtins.map (host: { name = host.name; value = host; }) hosts))."${config.networking.hostName}";
in
{
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ self.ip ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard-keys/private";
      mtu = 1432;

      peers =
        (map
          (host: {
            name = host.name;
            publicKey = host.publicKey;
            allowedIPs = host.allowedIPs;
            endpoint = host.endpoint;
            persistentKeepalive = if host.endpoint != null then 25 else null;
          })
          (builtins.filter
            (host: host.name != config.networking.hostName && (self.endpoint != null || host.endpoint != null))
            hosts)
        );
    };
  };
}
