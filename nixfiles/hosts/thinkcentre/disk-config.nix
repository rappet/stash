# Example to create a bios compatible gpt partition
{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd-1";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "true";
        };
        options.ashift = "12";
        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              #encryption = "aes-256-gcm";
              #keyformat = "passphrase";
              #keylocation = "prompt";
            };
            mountpoint = "/";
          };
          "root/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
            mountpoint = "/nix";
          };
          "root/media" = {
            type = "zfs_fs";
            options.mountpoint = "/var/media";
            options.compression = "off";
            options.atime = "off";
            mountpoint = "/var/media";
          };
          "root/postgresql" = {
            type = "zfs_fs";
            options = {
              mountpoint = "/var/lib/postgresql";
              recordsize = "16k";
              compression = "zstd-fast";
              primarycache = "metadata";
            };
            mountpoint = "/var/lib/postgresql";
          };
        };
      };
    };
  };
}
