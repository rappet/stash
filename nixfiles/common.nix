# common files for NixOS
{ config, pkgs, ... }:

{
  imports =
    [
      <home-manager/nixos>
    ];


  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    htop
    ripgrep
    home-manager
    wget
    neovim
    pciutils
    file
    ncdu
    fd
  ];
  
  users.users.rappet = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      plasma-pa
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkdt1hQWygxOuny4YlSNK5hGc+wDz3q2xyE8Y05DS3+ rappet@x230.rappet.de"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMz+WvOHfl9Er2QIdQsP/z4Qifk8uj75RfNpVa2WVDr rappet@MacBook-Air-von-Raphael.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5JIcEqbIaq/pBCbaU1AV3V2Mor1ZdgKoO3O9vJqW4f rappet@katze"
    ];
  };

  home-manager.users.rappet = import ./home/home.nix;

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
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
}