{ pkgs, lib, system, rust-cli, ... }:

let
  theme = import ./theme.nix;
  gpg-key = "6116F3CD99CB533F07E4E1441829D5210E0EEC51";
  my-python-packages = python-packages: with python-packages; [
    pandas
    numpy
    matplotlib
    requests
    rich
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
  ffmpeg-full-unfree = pkgs.ffmpeg-full.overrideAttrs (old: rec {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
  });
  common-packages = with pkgs; [
    # CLI
    thefuck
    neofetch
    mc
    binwalk
    xxd
    ripgrep
    bottom
    gnupg
    pinentry-gnome
    glow
    age
    # Networking
    bgpq4
    nmap
    tshark
    inetutils
    # Nix
    nixpkgs-fmt
    rnix-lsp
    # Publishing
    graphviz
    texlive.combined.scheme-full
    pandoc
    # Media
    ffmpeg-full-unfree
    yt-dlp
    # Database
    clickhouse-cli
    mosh
  ];
  linux-packages = with pkgs; if stdenv.isLinux then [
    mold
    binutils
  ] else [ ];
  packages = common-packages ++ linux-packages;
in
{
  imports = [
    ./sway.nix
    ./modules/neovim
  ];



  home.username = "rappet";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/rappet" else "/home/rappet";
  home.stateVersion = "22.05";
  home.packages = packages;

  # temporary hack for NixOS nstableu
  nixpkgs.overlays = [
    (self: super: {
      fcitx-engines = pkgs.fcitx5;
    })
  ];
  fonts.fontconfig.enable = lib.mkForce true;

  accounts.email = import ./email.nix;

  programs = {
    bash = {
      enable = true;
      historySize = 100000;
    };
    zsh = import ./programs/zsh.nix;
    fish.enable = true;
    home-manager.enable = true;
    neovim-config.enable = true;
    helix = {
      enable = true;
      languages.language = [
        {
          name = "rust";
          auto-format = true;

        }
      ];
      settings = {
        theme = "gruvbox";
        editor = {
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
        };
      };
    };
    git = import ./programs/git.nix { gpg-key = gpg-key; };
    password-store = {
      enable = true;
      settings = {
        PASSWORD_STORE_DIR = "$HOME/.password-store";
        PASSWORD_STORE_KEY = gpg-key;
        PASSWORD_STORE_CLIP_TIME = "60";
      };
    };
    starship = import ./programs/starship.nix;
    tmux = import ./programs/tmux.nix { pkgs = pkgs; };
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    alacritty = import ./programs/alacritty.nix {
      theme = theme;
    };
    kitty = import ./programs/kitty.nix {
      pkgs = pkgs;
      theme = theme;
    };
    fzf.enable = true;
    eza.enable = true;
    eza.enableAliases = true;
    neomutt.enable = true;
    mbsync.enable = true;
    man = {
      enable = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    z-lua = {
      enable = true;
      enableAliases = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    ssh = {
      enable = true;
      matchBlocks = {
        storagebox = {
	        hostname = "u215491.your-storagebox.de";
	        user = "u215491";
	        port = 23;
        };
        chaosdorf = {
          host = "chaosdorf";
	        hostname = "shells.chaosdorf.de";
	        user = "rappet";
        };
      };
    };
  };

  home.sessionVariables = {
    PATH = "\$HOME/.cargo/bin:\$PATH";
  };

  xsession.windowManager.i3 =
    if pkgs.stdenv.isLinux then {
      enable = true;
      config = {
        modifier = "Mod1";
        terminal = "$HOME/.nix-profile/bin/kitty";
      };
    } else { };

  services.gpg-agent =
    if pkgs.stdenv.isLinux then {
      enable = true;
      pinentryFlavor = "gnome3";
    } else { };
}
