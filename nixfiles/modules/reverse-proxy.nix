{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.reverse-proxy;
in
{
  options.reverse-proxy = {
    enable = mkEnableOption "reverse-proxy config";

    sniProxy = mkOption {
      description = ''
        SNI proxy settings
      '';
      default = { };
      type = types.submodule {
        enable = mkEnabkeOption "reverse-proxy sni config";
      };
    };
  };

  config = mkIf cfg.enable
    {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedBrotliSettings = true;
        recommendedTlsSettings = true;

        defaultHTTPListenPort = 8080;
        defaultSSLListenPort = 8443;
      };
    };
}
