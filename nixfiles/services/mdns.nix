{ config, pkgs, ... }:

{
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
      domain = true;
      # this is not really a secret, yes you know my OS version. Good luck.
      hinfo = true;
    };
  };
}
