{ gpg-key, ... }:
{
  enable = true;
  userName = "Raphael Peters";
  userEmail = "rappet@rappet.de";
  signing = {
    key = gpg-key;
    signByDefault = true;
  };
  difftastic.enable = true;
  lfs.enable = true;
  extraConfig = {
    core.editor = "nvim";
    pull.rebase = true;
    init.defaultBranch = "main";
  };
}
