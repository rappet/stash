{ pkgs, ... }:

let
  theme = import ./theme.nix;
  my-python-packages = python-packages: with python-packages; [
    pandas
    numpy
    matplotlib
    requests
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
in
  {
    home.stateVersion = "22.05";
    home.packages = with pkgs; [
      pkgconfig
      cmake
      thefuck
      rustc
      cargo
      rust-analyzer
      libiconv
      nixpkgs-fmt
      bgpq4
      nodejs
      ffmpeg-full
      neofetch
      mc
      nmap
      python-with-my-packages
      binwalk
      youtube-dl
      graphviz
      xxd
      rusty-man
    ];

    accounts.email = import ./email.nix;

    programs = {
      bash.enable = true;
      zsh = import ./programs/zsh.nix;
      fish.enable = true;
      home-manager.enable = true;
      neovim = import ./programs/neovim.nix {
        pkgs = pkgs;
      };
      git = import ./programs/git.nix;
      password-store = {
        enable = true;
        settings = {
          PASSWORD_STORE_DIR = "$HOME/.password-store";
          PASSWORD_STORE_KEY = "6116F3CD99CB533F07E4E1441829D5210E0EEC51";
          PASSWORD_STORE_CLIP_TIME = "60";
        };
      };
      starship = import ./programs/starship.nix;
      tmux = {
        enable = true;
        baseIndex = 1;
        extraConfig = ''
          setw -g mouse on
        '';
      };
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
        theme = theme;
      };
      fzf.enable = true;
      exa.enable = true;
      exa.enableAliases = true;
      neomutt.enable = true;
      mbsync.enable = true;
      man = {
        enable = true;
      };
    };
  }
