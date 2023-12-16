{ config, pkgs, system, ... }:

let
  x86_64_packages = with pkgs; if system == "x86_64-linux" then [
    discord
    blender
    bitwarden
  ] else [ ];
in
{
  imports =
    [
      ../services/mdns.nix
      ./sway.nix
    ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  networking.networkmanager.enable = true;
  users.users.rappet.extraGroups = [ "networkmanager" ];

  # discord
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    firefox-wayland
    thunderbird
    nheko
    mumble
    quasselClient

    qjackctl

    krita
    inkscape
    vlc

    wayland
    dracula-theme

    home-manager
  ] ++ x86_64_packages;

  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "FiraCode" "Hack" ]; }) ];

  sound.enable = true;
  security.rtkit.enable = true;
  users.extraUsers.rappet.extraGroups = [ "audio" ];
  nixpkgs.config.pulseaudio = true;

  programs.dconf.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.printing.enable = true;

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    layout = "us";
    xkbVariant = "intl";
  };
}
