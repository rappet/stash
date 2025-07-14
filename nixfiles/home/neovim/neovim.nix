{ pkgs, ... }:

{
  enable = true;
  viAlias = true;
  vimAlias = true;
  plugins = with pkgs.vimPlugins; [
    {
      plugin = vim-airline;
      #config = "let g:airline_powerline_fonts = 1";
    }
    vim-airline-themes
    tokyonight-nvim
    vim-nix
    vim-css-color
    {
      plugin = nerdtree;
      config = ''
        nnoremap <F2> :tabnew<CR>:Explore<CR>
        nnoremap <F3> :tabp<CR>
        nnoremap <F4> :tabn<CR>
        nnoremap <C-t> :NERDTreeTabsToggle<CR>
        nnoremap <C-f> :NERDTreeFocusToggle<CR>
      '';
    }
    nerdtree-git-plugin
    vim-nerdtree-tabs
    vim-gitgutter
    vim-commentary
    vim-fugitive
    vim-surround
    awesome-vim-colorschemes
    {
      plugin = rust-vim;
      config = ''
        let g:rustfmt_autosave = 1
      '';
    }
    nvim-lspconfig
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    cmp-cmdline
    nvim-cmp
    ultisnips
    cmp-nvim-ultisnips
    fzf-vim
    dracula-vim
    editorconfig-nvim
    # telescope
    plenary-nvim
    {
      plugin = telescope-nvim;
      config = ''
        " Find files using Telescope command-line sugar.
        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
      '';
    }
    vim-devicons
    rust-tools-nvim
  ];
  #coc.enable = true;
  extraConfig =
    builtins.readFile ./neovim.vim + "\nlua << EOF\n" + builtins.readFile ./neovim.lua + "\nEOF";
}
