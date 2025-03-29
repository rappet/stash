{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.config.reverse-proxy;
 in
 {
  options.reverse-proxy = {
    enable = mkEnableOption "reverse-proxy config";
  };

  config = mkIf cfg.enable = {
    services.nginx = {
      enable = true;
    };
  };
 }

