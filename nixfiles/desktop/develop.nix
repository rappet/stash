{ config, pkgs, system, ... }:

let
  x86_64_packages = with pkgs; if system == "x86_64-linux" then [
    jetbrains.clion
    jetbrains.idea-ultimate
    jetbrains.idea-community
  ] else [ ];
in
{
  # vscode, jetbrains
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    qemu

    vscode

    wireshark
    podman-tui
    podman-compose

    picocom
    kicad

    obsidian
  ] ++ x86_64_packages;

  programs.wireshark.enable = true;

  virtualisation.podman.enable = true;
}
