{ config, pkgs, ... }:

{
  # vscode, jetbrains
  nixpkgs.config.allowUnfree = true;

  programs.steam = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    minecraft
  ];
}
