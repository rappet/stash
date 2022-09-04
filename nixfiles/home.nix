{ pkgs, ... }:

{
  home.stateVersion = "22.05";
  home.packages = with pkgs; [
    pkgconfig
    cmake
    thefuck
    cargo
    rustc
    rust-analyzer
    libiconv
    nixpkgs-fmt
    fish
    tmux
    bgpq4
    nodejs
    ffmpeg-full
    jq
  ];

  programs = {
    bash.enable = true;
    zsh = import ./zsh.nix;
    fish.enable = true;
    home-manager.enable = true;
    neovim = import ./neovim.nix {
      pkgs = pkgs;
    };
    git = import ./git.nix;
    starship.enable = true;
    tmux.enable = true;
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    alacritty = {
      enable = true;
      settings = {
        window.padding = {
          x = 4;
          y = 4;
        };
        font = {
          normal.family = "FiraCode Nerd Font Mono";
          size = 12.0;
        };
      };
    };
  };
}
