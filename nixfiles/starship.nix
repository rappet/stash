let
  user = {
    bg = "#b16286";
    fg = "#000000";
  };
  directory = {
    bg = "#d65d0e";
    fg = "#000000";
  };
  git = {
    bg = "#d79921";
    fg = "#000000";
  };
  tools = {
    bg = "#83a598";
    fg = "#000000";
  };
  time = {
    bg = "#458588";
    fg = "#000000";
  };
in
{
  enable = true;
  settings = {
    # From pastel-powerline preset:
    # https://starship.rs/presets/pastel-powerline.html
    format = "╭─[](${user.bg})$username[](bg:${directory.bg} fg:${user.bg})$directory[](fg:${directory.bg} bg:${git.bg})$git_branch$git_status[](fg:${git.bg} bg:${tools.bg})$c$elixir$elm$golang$haskell$java$julia$nodejs$nim$rust[](fg:${tools.bg} bg:#06969A)$docker_context[](fg:#06969A bg:${time.bg})$time[ ](fg:${time.bg})\n╰─";

    username = {
      show_always = true;
      style_user = "bg:${user.bg} fg:${user.fg}";
      style_root = "bg:${user.bg} fg:${user.fg}";
      format = ''[ $user ]($style)'';
    };

    directory = {
      style = "bg:${directory.bg} fg:${directory.fg}";
      format = ''[ $path ]($style)'';
      truncation_length = 3;
      truncation_symbol = "…/";
      substitutions = {
        Documents = " ";
        Downloads = " ";
        Music = " ";
        Pictures = " ";
      };
    };

    c = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    docker_context = {
      symbol = " ";
      style = "bg:#06969A";
      format = ''[ $symbol $context ] ($style) $path'';
    };

    elixir = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    elm = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    git_branch = {
      symbol = "";
      style = "bg:${git.bg} fg:${git.fg}";
      format = ''[ $symbol $branch ]($style)'';
    };

    git_status = {
      style = "bg:${git.bg} fg:${git.fg}";
      format = ''[ $all_status$ahead_behind ]($style)'';
    };

    golang = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    haskell = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    java = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    julia = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    nodejs = {
      symbol = "";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    nim = {
      symbol = " ";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    rust = {
      symbol = "";
      style = "bg:${tools.bg} fg:${tools.fg}";
      format = ''[ $symbol ($version) ]($style)'';
    };

    time = {
      disabled = false;
      time_format = "%R"; # Hour:Minute Format
      style = "bg:${time.bg} fg:${time.fg}";
      format = ''[ ♥ $time ]($style)'';
    };
  };
}
