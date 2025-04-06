{ config, ... }:

let
  hosts = [
    {
      name = "fra1-de";
      publicKey = "DxJmELlueuf/1YnlMA9FUuqI0GPPeF5yW1EMc5G8s1g=";
      endpoint = "193.148.249.188:51820";
    }
    {
      name = "thinkcentre";
      publicKey = "xSG3PDLprnlUkPGCwAj7uTjxCmmR2M8M8cXsWBK1CVs=";
      endpoint = null;
    }
    {
      name = "framework";
      publicKey = "LbrjQAvVKt9MrcD+6NQ+3KcYCdtVw7RFblveaTB1xHA=";
      endpoint = null;
    }
    {
      name = "services";
      ip = "2a0e:46c6:0:300::1";
      publicKey = "G+dlubY61jRxl/E4f9xfBeD4gO3E47084XxDV3Hhl2g=";
      endpoint = "91.99.19.52:51820";
    }
  ];
  self = (builtins.listToAttrs (builtins.map (host: { name = host.name; value = host; }) hosts))."${config.networking.hostName}";
  selfNodeId = builtins.substring 0 4 (builtins.hashString "sha256" self.name);
  ula = "fdd1:6b5f:0b54";
in
{
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard = {
    enable = true;
    interfaces.wg0 = {
      ips = [ "${ula}:${selfNodeId}::1" ];
      listenPort = 51820;
      privateKeyFile = "/root/wireguard-keys/private";
      mtu = 1432;

      peers =
        (map
          (host:
            let
              nodeId = builtins.substring 0 4 (builtins.hashString "sha256" host.name);
            in
            {
              name = host.name;
              publicKey = host.publicKey;
              allowedIPs = [ "${ula}:${nodeId}::/64" ];
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
