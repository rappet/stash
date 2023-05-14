{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.knot.enable = true;
  services.knot.extraConfig = ''
    server:
      listen: 0.0.0.0@53
      listen: ::@53

    remote:
      - id: he_slave
        address: 216.218.130.2

    acl:
      - id: he_rule
        address: [216.218.133.2, 2001:470:600::2]
        action: transfer
      - id: rfc2136_rule
        address: [127.0.0.1, ::1]
        action: update

    template:
      - id: he_slave
        notify: he_slave
        acl: [he_rule]
      - id: rfc2136
        acl: [rfc2136_rule]


    zone:
      - domain: rappet.xyz
        file: ${./zones/rappet.xyz.zone}
        template: he_slave
      - domain: _acme-challenge.rappet.xyz
        template: rfc2136
      - domain: rotkohl.foo
        file: ${./zones/rotkohl.foo.zone}
        template: he_slave

    log:
      - target: syslog
        any: info
  '';
}
