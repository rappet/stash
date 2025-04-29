{
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    ../../common.nix
    ../../services/mdns.nix
    #../../services/samba.nix

    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    ../../wg-mesh.nix
  ];

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "zfs.zfs_arc_max=1073741824"
  ];

  networking.hostName = "apu";
  # magic not unique host id, for ZFS
  networking.hostId = "00bab10c";

  networking.interfaces = {
    enp1s0 = {
      useDHCP = true;
    };
  };
}
