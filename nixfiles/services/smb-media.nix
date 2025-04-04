{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/var/media" = {
    device = "//u215491-sub6.your-storagebox.de/u215491-sub6";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1001";

      in
      [ "${automount_opts},seal,cache=none,credentials=${config.age.secrets.smb-media.path}" ];
  };
  fileSystems."/var/torrents" = {
    device = "//u215491-sub6.your-storagebox.de/u215491-sub6/torrents";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=70";
      in
      [ "${automount_opts},seal,cache=none,credentials=${config.age.secrets.smb-media.path}" ];
  };

  age.secrets.smb-media.file = ../secret/smb-media.age;

  services.postgresqlBackup.databases = config.services.postgresql.ensureDatabases;
}
