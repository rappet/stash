{ pkgs, ... }:

{
  home.packages = [
    pkgs.pkgconfig
    pkgs.cmake
    # for darwin
    pkgs.libiconv
    pkgs.cargo
    pkgs.rustc
    pkgs.rust-analyzer
    pkgs.bat
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      :colorscheme default
      :set number
      
      lua << EOF
      require'lspconfig'.rust_analyzer.setup{}
      EOF
    '';

    plugins = with pkgs.vimPlugins; [
      editorconfig-vim
      ctrlp
      gruvbox
      nerdtree
      tabular
      vim-nix
      vim-markdown
      nvim-lspconfig
    ];
  };

  programs.fish = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.dimensions = {
        columns = 140;
        lines = 40;
      };
      font.normal.family = "FiraCode Nerd Font Mono";
    };
  };

  programs.tmux = {
    enable = true;
  };
}
