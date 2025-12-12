{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.home-cli-config;
in
{
  options.home-cli-config = {
    enable = mkEnableOption "rappet's home config - CLI apps";

    user = {
      email = mkOption {
        type = types.str;
        default = null;
        example = "foo@example.org";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # CLI
      neofetch
      binwalk
      xxd
      ripgrep
      bottom
      gnupg
      pinentry-gnome3
      glow
      age
      # Networking
      bgpq4
      nmap
      tshark
      inetutils
      # Nix
      nixpkgs-fmt
      # Publishing
      graphviz
      pandoc
      # Media
      yt-dlp
      # Database
      clickhouse-cli
      mosh
      # Cloud
      kubectl
      kubernetes-helm
    ];

    programs = {
      bash = {
        enable = true;
        historySize = 100000;
      };
      zsh = import ./programs/zsh.nix;
      fish.enable = true;
      home-manager.enable = true;
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
      git = import ./programs/git.nix;
      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "$HOME/.password-store";
          PASSWORD_STORE_CLIP_TIME = "60";
        };
      };
      starship.enable = true;
      tmux = import ./programs/tmux.nix { pkgs = pkgs; };
      bat = {
        enable = true;
        config = {
          pager = "less -FR";
        };
      };
      fzf.enable = true;
      eza.enable = true;
      eza = {
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
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
    };
  };
}
