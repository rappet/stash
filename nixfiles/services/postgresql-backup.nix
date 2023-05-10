{ config, pkgs, ... }:

{
  services.postgresqlBackup = {
    enable = true;
    compressionLevel = 9;
    compression = "zstd";
  };
}
