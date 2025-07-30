{
  modulesPath,
  pkgs,
  inputs,
  system,
  config,
  ...
}:
{
  imports = [
    #./hardware-configuration.nix
    ../../common.nix
    ../../services/infrastructure/loadbalancer.nix
    ../../services/infrastructure/garage.nix
    ../../services/infrastructure/web.nix
    ../../services/infrastructure/postgresql-backup.nix
    ../../services/apps/jellyfin.nix
    ../../services/apps/transmission.nix
    #../../services/apps/bluemap.nix
    ../../services/apps/gitlab.nix
    #./backup.nix

    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    ../../wg-mesh.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostName = "thinkcentre";
    domain = "rappet.xyz";
    hostId = "c1037a3f";
    extraHosts = "91.99.19.52 ns1.rappet.xyz";
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "eno1";
      enableIPv6 = true;
    };
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  services.zfs = {
    autoScrub.enable = true;
  };

  services.sanoid = {
    enable = true;

    datasets = {
      "zroot/root" = {
        use_template = [ "data" ];
      };
    };

    templates.data = {
      frequently = 0;
      hourly = 36;
      daily = 30;
      monthly = 3;
      yearly = 0;
      autosnap = true;
      autoprune = true;
    };
  };

  systemd.timers."sync-minecraft" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "sync-minecraft.service";
    };
  };

  systemd.services."sync-minecraft" = {
    path = [ pkgs.openssh ];
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync -av services.rappet.xyz:/var/lib/minecraft /var/lib/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
