# common files for NixOS
{
  config,
  pkgs,
  inputs,
  ...
}:

let
  ssh-keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5JIcEqbIaq/pBCbaU1AV3V2Mor1ZdgKoO3O9vJqW4f rappet@katze"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyGxZI3l3PBv+zO6ZxgfP1hiMiQWwNevVtgfuUeBFDI rappet@rappet-framework"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbkmGVa8uzywkHE/VQEzDW4aQNdoJcYQ1gkvhcytTlZ rappet@thinkcentre"
  ];
  ports = import ./services/ports.nix;
in
{
  imports = [
    ./backup.nix
  ];

  nixpkgs.overlays = [ inputs.tlslb.overlays.default ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 1d";
  };

  security = {
    polkit.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    htop
    ripgrep
    bat
    wget
    pciutils
    usbutils
    file
    ncdu
    fd
    duperemove
    rclone
    restic
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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.mosh.enable = true;

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

  #services.comin = {
  #  enable = true;
  #  remotes = [{
  #    name = "origin";
  #    url = "https://github.com/rappet/stash.git";
  #    branches.main.name = "main";
  #  }];
  #  flakeSubdirectory = "nixfiles";
  #};

  system.autoUpgrade = {
    enable = true;
    flake = "github:rappet/stash/main?dir=nixfiles";
    flags = [
      # deprecated (still works), alias for nix flakes update, replaced when system.autoUpgrade module is updated
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "*-*-* 01,05,10,16,22:00:00";
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "06:00";
    };
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "ethtool"
      ];
      port = ports.prometheus-node-exporter;
      # Security: Have fun scraping, I don't care
      openFirewall = true;
      listenAddress = "[::]";
    };
  };

  networking.nftables.enable = true;

  programs.ssh.extraConfig = ''
    Host storagebox
      Port 23
      User u215491
      HostName u215491.your-storagebox.de
  '';

  programs.ssh.knownHostsFiles = [
    (pkgs.writeText "known-hosts.keys" ''
      [u215491.your-storagebox.de]:23 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs
      [u215491.your-storagebox.de]:23 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==
      [u2
      15491.your-storagebox.de]:23 ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGK0po6usux4Qv2d8zKZN1dDvbWjxKkGsx7XwFdSUCnF19Q8psHEUWR7C/LtSQ5crU/g+tQVRBtSgoUcE8T+FWp5wBxKvWG2X9gD+s9/4zRmDeSJR77W6gSA/+hpOZoSE+4KgNdnbYSNtbZH/dN74EG7GLb/gcIpbUUzPNXpfKl7mQitw==
    '')
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "certbot@rappet.de";
  };

  age.secrets.letsencrypt-hetzner = {
    file = ./secret/letsencrypt-hetzner.age;
    owner = "root";
    group = "root";
  };

  system.stateVersion = "23.11";
}
