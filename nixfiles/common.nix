# common files for NixOS
{ config, pkgs, inputs, ... }:

let
  ssh-keys = [
    # this key is broken - for some reason lowercased
    "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaihkdt1hqwygxouny4ylsnk5hgc+wdz3q2xye8y05ds3+ rappet@x230.rappet.de"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMz+WvOHfl9Er2QIdQsP/z4Qifk8uj75RfNpVa2WVDr rappet@MacBook-Air-von-Raphael.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5JIcEqbIaq/pBCbaU1AV3V2Mor1ZdgKoO3O9vJqW4f rappet@katze"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6LcV2AdljIQBFYWE7tRUvEfTfbNqFM3J5N8cmz50Z rappet@ibook-nixos"
  ];
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security = {
    polkit.enable = true;
  };


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

    description = "Raphael Peters";

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
  services.tailscale.enable = true;
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  system.stateVersion = "23.05";
}
