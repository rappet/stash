{ config, pkgs, ... }:

let
  ports = import ./ports.nix;
in
{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        users.shelly_netzwerk = {
          acl = [
            "readwrite shelly/netzwerk/#"
          ];
          passwordFile = config.age.secrets.mqtt-shelly-auth.path;
        };
        users.shelly_schreibtisch = {
          acl = [
            "readwrite shelly/schreibtisch/#"
          ];
          passwordFile = config.age.secrets.mqtt-shelly-auth.path;
        };
      }
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 1883 ];
  };


  age.secrets.mqtt-shelly-auth = {
    file = ../secret/mqtt-shelly-auth.age;
    owner = "mosquitto";
    group = "mosquitto";
  };
}
