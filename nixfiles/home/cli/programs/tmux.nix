{ pkgs, ... }:
{
  enable = true;
  baseIndex = 1;
  plugins = with pkgs.tmuxPlugins; [
    sensible
    yank
    gruvbox
  ];
  extraConfig = ''
    setw -g mouse on
  '';
}
