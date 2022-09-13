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
    nerdtree-git-plugin
    vim-nerdtree-tabs
    vim-gitgutter
    vim-commentary
    vim-fugitive
    vim-surround
    awesome-vim-colorschemes
    rust-vim
    nvim-lspconfig
    fzf-vim
  ];
  #coc.enable = true;
  extraConfig = builtins.readFile ./neovim.vim;
}
