{ theme, ... }:

{
  enable = true;
  settings = {
    font = {
      normal = {
        family = "FiraCode Nerd Font Mono";
        style = "Medium";
      };
      size = 12.0;
    };
    colors = {
      primary.background = theme.primary.bg;
      primary.foreground = theme.primary.fg;
      primary.dim_foreground = "#a5abb6";
      cursor = {
        text= "#2e3440";
        cursor= "#d8dee9";
      };
      normal = {
        black = "#282828";
        red = "#cc241d";
        green = "#98971a";
        yellow = "#d79921";
        blue = "#458588";
        magenta = "#b16286";
        cyan = "#689d6a";
        white = "#a89984";
      };
      bright = {
        black = "#928374";
        red = "#fb4934";
        green = "#b8bb26";
        yellow = "#fabd2f";
        blue = "#83a598";
        magenta = "#d3869b";
        cyan = "#8ec07c";
        white = "#ebdbb2";
      };
    };
  };
}
