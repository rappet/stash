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
}
