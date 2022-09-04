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
    zsh = import ./programs/zsh.nix;
    fish.enable = true;
    home-manager.enable = true;
    neovim = import ./programs/neovim.nix {
      pkgs = pkgs;
    };
    git = import ./programs/git.nix;
    starship = import ./programs/starship.nix;
    tmux.enable = true;
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };
    alacritty = import ./programs/alacritty.nix;
    fzf.enable = true;
  };
}
