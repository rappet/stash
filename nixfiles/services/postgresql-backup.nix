{ config, pkgs }:

{
  services.postgreSqlBackup = {
    enable = true;
    compressionLevel = 14;
    compression = "zstd";
    backupAll = true;
  };
}
