# common files for NixOS
{ config, pkgs, inputs, ... }:

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  system.autoUpgrade = {
    enable = true;
    flake = "github:rappet/stash/main?dir=nixfiles";
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "*:0/30";
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "06:00";
    };
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" "ethtool" ];
      port = ports.prometheus-node-exporter;
      # Security: Have fun scraping, I don't care
      openFirewall = true;
      listenAddress = "[::]";
    };
  };

  services.garage = {
    enable = true;
    package = pkgs.garage_1_x;
    settings = {
      db_engine = "sqlite";
      replication_factor = 3;
      rpc_bind_addr = "[::]:3901";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.eimer.rappet.xyz";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.eimer.rappet.xyz";
        index = "index.html";
      };
      k2v_api = {
        api_bind_addr = "[::]:3904";
      };
      admin = {
        api_bind_addr = "[::]:3903";
      };
    };
    environmentFile = config.age.secrets.garage-env.path;
  };

  networking.firewall = {
    allowedTCPPorts = [ 3901 3903 ];
  };

  age.secrets.garage-env = {
    file = ./secret/garage-env.age;
    owner = "root";
    group = "root";
  };

  networking.nftables.enable = true;

  system.stateVersion = "23.11";
}
