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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  users.groups.loadbalancer.members = [
    "nginx"
    "haproxy"
  ];
}
