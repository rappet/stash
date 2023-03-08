{ config, pkgs, ... }:

{
  # vscode, jetbrains
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    jetbrains.clion
    jetbrains.idea-ultimate
    vscode

    wireshark

    podman-tui
    podman-compose
  ];

  virtualisation.podman.enable = true;
}