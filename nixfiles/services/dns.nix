{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.knot.enable = true;
  services.knot.settingsFile = pkgs.writeText "knot.conf" ''
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
      - domain: 0.0.6.c.6.4.e.0.a.2.ip6.arpa
        file: ${./zones/0.0.6.c.6.4.e.0.a.2.ip6.arpa.zone}
        template: he_slave
      - domain: _acme-challenge.rappet.xyz
        template: rfc2136

    log:
      - target: syslog
        any: info
  '';
}
