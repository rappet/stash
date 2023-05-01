{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.neovim-config;
in {
  options.programs.neovim-config = {
    enable = mkEnableOption "neovim-config";
  };

  config = mkIf cfg.enable {
    programs.neovim = import ./neovim.nix { inherit pkgs; };
  };
}
