{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    python3
    bat
    gnupg
    mtr
    fish
    tmux
    ripgrep
    jc
    jq
  ];

  # TODO nix flakes setup + experimental version
  #nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/stash/nixfiles/hosts/ibook/darwin-configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  users.users.rappet = {
    name = "rappet";
    home = "/Users/rappet";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "services.rappet.de";
      system = "aarch64-linux";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUM3bmlPR21neDd0c0s0ekdSb3NnU2dTTm9PaGdRNXBkYzF6V1RuTFFPR00gcm9vdEBzZXJ2aWNlcwo=";
      sshUser = "root";
      sshKey = "/Users/rappet/.ssh/id_ed25519";
      maxJobs = 4;
    }
    {
      hostName = "katze.local";
      system = "x86_64-linux";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpsUkVhcDRPM1pxUmFpR0pxRTFJUFp0N3NOU1duQXJvSHRaTDRXZFl3eDUgcm9vdEBrYXR6ZQo=";
      sshUser = "rappet";
      sshKey = "/Users/rappet/.ssh/id_ed25519";
      maxJobs = 16;
    }
  ];
}
