{
  config,
  pkgs,
  system,
  inputs,
  ...
}:
{
  reverse-proxy = {
    enable = true;
    sniProxy.enabled = true;
  };

  environment.systemPackages = [
    pkgs.tlslb
  ];

  services.haproxy = {
    enable = true;
    config = builtins.readFile ./haproxy.conf;
  };

  services.tlslb = {
    enable = true;
    config = ''
      [frontends.https]
      listen-address = "[::]:9443"
      type = "tls"

      [backends."rappet.xyz"]
      addresses = ["rappet.xyz:443"]

      [backends."mc.rappet.xyz"]
      addresses = ["thinkcentre.rappet.xyz:8443"]

      [backends."md.rappet.xyz"]
      addresses = ["services.rappet.xyz:8443"]

      [backends."social.rappet.xyz"]
      addresses = ["services.rappet.xyz:8443"]

      [backends."netbox.rappet.xyz"]
      addresses = ["services.rappet.xyz:8443"]
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    9443
  ];

  users.groups.loadbalancer.members = [
    "nginx"
    "haproxy"
  ];
}
