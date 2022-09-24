{ theme, ... }:

{
  enable = true;
  settings = {
    background = theme.primary.bg;
    foreground = theme.primary.fg;
    cursor = theme.primary.fg;
    strip_trailing_spaces = "smart";
    resize_in_steps = true;
    macos_titlebar_color = "background";
  };
}
