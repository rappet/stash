{
  enable = true;
  history = {
    size = 100000;
  };
  oh-my-zsh = {
    enable = true;
    plugins = [
      "git"
    ];
    theme = "robbyrussell";
  };
  initExtra = ''
    export PATH="$HOME/.cargo/bin:$PATH";
  '';
}
