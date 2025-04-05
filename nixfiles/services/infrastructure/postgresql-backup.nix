{ config, pkgs, ... }:

{
  services.postgresqlBackup = {
    enable = true;
    startAt = "*-*-* 02,14:00:00";
  };
}
