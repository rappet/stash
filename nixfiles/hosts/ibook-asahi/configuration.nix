# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

with lib.strings;

let
  dedupe-paths = [ "/home" ];
in
{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./apple-silicon-support
    ../../common.nix
    ../../desktop/desktop.nix
    ../../desktop/develop.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.luks.devices.nixos-asahi-pv.device = "/dev/disk/by-label/nixos-asahi-luks";

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/btrfs".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
  };

  networking.hostName = "ibook-nixos";

  fonts.fontconfig.antialias = true;

  environment.pathsToLink = [ "/libexec" ];

  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    withRust = true;
    addEdgeKernelConfig = true;
    useExperimentalGPUDriver = true;
  };

  hardware.bluetooth.enable = true;

  services.xserver.videoDrivers = [ "apple" ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };

  systemd.timers."dedupe-home" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "24h";
      Unit = "dedupe-home.service";
    };
  };

  systemd.services."dedupe-home" = {
    script = ''
        set -eu
        ${pkgs.duperemove}/bin/duperemove -drh ${concatStringsSep " " dedupe-paths}
   '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}

