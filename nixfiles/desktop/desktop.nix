{ config, pkgs, ... }:

let
  x86_64_packages = with pkgs; if builtins.currentSystem == "x86_64-linux" then [
    discord
    blender
    bitwarden
  ] else [];
in
{
  imports =
   [
      <home-manager/nixos>
      ../services/mdns.nix
   ];

  # discord
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    firefox
    thunderbird
    element-desktop
    nheko

    qjackctl

    krita
    inkscape
    vlc
    superTux
    superTuxKart

    home-manager
  ] ++ x86_64_packages;

  home-manager.users.rappet = import ../home/home.nix;


  sound.enable = true;
  security.rtkit.enable = true;
  users.extraUsers.rappet.extraGroups = [ "audio" ];
  nixpkgs.config.pulseaudio = true;

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
