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

  programs.bash.enable = true;
  programs.zsh = import ./zsh.nix;
  programs.fish.enable = true;
  programs.home-manager.enable = true;
  programs.neovim = import ./neovim.nix {
    pkgs = pkgs;
  };
  programs.git = import ./git.nix;
  programs.starship = {
    enable = true;
  };
  programs.tmux = {
    enable = true;
  };
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
  };
  programs.alacritty = {
    enable = true;
  };
}
