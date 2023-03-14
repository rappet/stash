{ config, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "met"
      "radio_browser"
    ];
    config = {
      default_config = {};
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
    };
  };


  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    virtualHosts."apu.local" = {
      forceSSL = false;
      enableACME = false;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/hass" = {
        return = "302 /hass/";
      };
      locations."/hass/" = {
        proxyPass = "http://[::1]:8123/";
        proxyWebsockets = true;
      };
    };
  };


  networking.firewall.allowedTCPPorts = [ 80 443 8123 ];
}