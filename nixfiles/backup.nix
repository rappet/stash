{ modulesPath, pkgs, inputs, system, config, ... }: {
  services.restic.backups.var = {
    repository = "sftp:storagebox:backup-server";
    timerConfig = {
      OnCalendar = "*-*-* 04,10,16,22:00:00";
      Persistent = true;
    };
    runCheck = true;
    passwordFile = config.age.secrets.restic-backup-password.path;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];
    paths = [
      "/var"
    ];
    exclude = [
        "/var/cache"
        "/var/lock"
        "/var/spool"
        "/var/run"
        "/var/tmp"

        "/var/log"

        "/var/media"
        "/var/torrents"
    ];
    inhibitsSleep = true;
  };

  age.secrets.restic-backup-password = {
    file = ./secret/restic-backup-password.age;
  };
}
