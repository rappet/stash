{ config, pkgs, ... }:

{
  services.postgresqlBackup = {
    enable = true;
    compressionLevel = 9;
    compression = "zstd";
    startAt = "*-*-* 02,14:00:00";
  };
}
