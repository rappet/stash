{ pkgs, ... }:

{
  enable = true;
  viAlias = true;
  vimAlias = true;
  plugins = with pkgs.vimPlugins; [
    vim-airline
    vim-airline-themes
    vim-nix
    vim-css-color
    nerdtree
    vim-gitgutter
    vim-commentary
    vim-fugitive
    vim-surround
    awesome-vim-colorschemes
    rust-vim
    nvim-lspconfig
  ];
  extraConfig = ''
    set relativenumber
    syntax enable
    filetype plugin indent on

    lua << EOF
    require'lspconfig'.rust_analyzer.setup{}
    EOF
  '';
}
