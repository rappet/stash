{ theme, ... }:

{
  enable = true;
  settings = {
    background = theme.bg;
    foreground = theme.fg;
    cursor = theme.fg;
    strip_trailing_spaces = "smart";
    resize_in_steps = true;
    macos_titlebar_color = "background";
  };
}
