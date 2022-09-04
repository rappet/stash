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
    bgpq4
    nodejs
    ffmpeg-full
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
    starship = import ./starship.nix;
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
        font = {
          normal = {
            family = "FiraCode Nerd Font Mono";
            style = "Medium";
          };
          size = 12.0;
        };
        colors.primary.background = "#282a36";
      };
    };
    fzf.enable = true;
  };
}
