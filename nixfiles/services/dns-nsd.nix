{ config, pkgs, ... }:

let
  he-xfr = [
    "216.218.133.2 NOKEY"
    "2001:470:600::2 NOKEY"
  ];
  he-notify = [
    "216.218.130.2 NOKEY"
  ];

in
rec {
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.nsd = {
    enable = true;
    interfaces = [ "0.0.0.0" ];
    zones = {
      "rappet.xyz" = {
        data = builtins.readFile ./zones/rappet.xyz.zone;
        provideXFR = he-xfr;
        notify = he-notify;
      };
    };
  };
}
