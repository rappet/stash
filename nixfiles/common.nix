# common files for NixOS
{ config, pkgs, ... }:

let
  ssh-keys = [
    "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaihkdt1hqwygxouny4ylsnk5hgc+wdz3q2xye8y05ds3+ rappet@x230.rappet.de"
    "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaiomz+wvohfl9er2qidqsp/z4qifk8uj75rfnpva2wvdr rappet@macbook-air-von-raphael.local"
    "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaio5jiceqbiaq/pbcbau1av3v2mor1zdgkoo3o9vjqw4f rappet@katze"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6LcV2AdljIQBFYWE7tRUvEfTfbNqFM3J5N8cmz50Z rappet@ibook-nixos"
  ];
in {
  imports =
    [];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    htop
    ripgrep
    wget
    neovim
    pciutils
    usbutils
    file
    ncdu
    fd
    duperemove
  ];

  users.users.rappet = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.

    openssh.authorizedKeys.keys = ssh-keys;
  };

  users.users.root = {
    openssh.authorizedKeys.keys = ssh-keys;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "yes";
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
}
