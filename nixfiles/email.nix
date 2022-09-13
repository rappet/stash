{
  accounts.gmail = {
    address = "raphael.r.peters@gmail.com";
    realName = "Raphael Peters";
    signature = {
      text = ''
          Mit freundlichen Grüßen
          Raphael Peters
          https://www.raphaelpeters.de/
      '';
      showSignature = "append";
    };
    primary = true;
    flavor = "gmail.com";
    imap.host = "imap.gmail.com";
    smtp.host = "smtp.gmail.com";
    passwordCommand = "pass show gmail.com/raphael.r.peters@gmail.com/app";
    neomutt.enable = true;
    mbsync = {
      enable = true;
      create = "maildir";
    };
  };
}
