{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.bluemap;
  format = pkgs.formats.hocon { };

  coreConfig = format.generate "core.conf" cfg.coreSettings;
  webappConfig = format.generate "webapp.conf" cfg.webappSettings;
  webserverConfig = format.generate "webserver.conf" cfg.webserverSettings;

  mapsFolder = pkgs.linkFarm "maps" (
    lib.attrsets.mapAttrs' (
      name: value: lib.nameValuePair "${name}.conf" (format.generate "${name}.conf" value)
    ) cfg.maps
  );

  addonsFolder = pkgs.linkFarm "addons" (
    lib.attrsets.mapAttrs' (name: value: lib.nameValuePair "${name}.jar" value) cfg.addons
  );

  storageFolder = pkgs.linkFarm "storage" (
    lib.attrsets.mapAttrs' (
      name: value: lib.nameValuePair "${name}.conf" (format.generate "${name}.conf" value)
    ) cfg.storage
  );

  configFolder = pkgs.linkFarm "bluemap-config" {
    "maps" = mapsFolder;
    "storages" = storageFolder;
    "core.conf" = coreConfig;
    "webapp.conf" = webappConfig;
    "webserver.conf" = webserverConfig;
    "packs" = pkgs.linkFarm "packs" cfg.packs;
    "addons" = addonsFolder;
  };
in
{
  services.minecraft-server = {
    enable = true;
    package = pkgs.papermcServers.papermc-1_21_4;
    eula = true;
    declarative = true;
    serverProperties = {
      server-port = 25565;
      difficulty = 3;
      gamemode = 0;
      max-players = 5;
      motd = "rappet's survival server";
      white-list = true;
      level-name = "Survival";
      view-distance = 16;
      spawn-protection = 0;
    };
    openFirewall = true;
    whitelist = {
      rappet = "588377a5-362f-4ea1-8195-9cf97dd7a884";
      Matttin = "684e849d-8186-4f57-90ed-41888024118a";
      Auravendill = "e84ffee0-0e0b-4c16-be29-293a383d96c4";
      Riki1675 = "29453242-c200-4b2d-a6e9-52ded64c5b43";
      SophieEntropie = "d2f25dc8-577b-4ae2-9834-5fb673c91815";
    };
  };

  services.bluemap = {
    enable = true;
    eula = true;
    host = "mc.rappet.xyz";
    defaultWorld = "${config.services.minecraft-server.dataDir}/${config.services.minecraft-server.serverProperties.level-name}";
    enableNginx = true;
    onCalendar = "03:10:00";

    maps =
      let
        cfg = config.services.bluemap;
      in
      {
        "overworld" = {
          world = "${cfg.defaultWorld}";
          ambient-light = 0.1;
          cave-detection-ocean-floor = -5;
        };

        "nether" = {
          world = "${cfg.defaultWorld}_nether/DIM-1";
          sorting = 100;
          sky-color = "#290000";
          void-color = "#150000";
          ambient-light = 0.6;
          world-sky-light = 0;
          remove-caves-below-y = -10000;
          cave-detection-ocean-floor = -5;
          cave-detection-uses-block-light = true;
          max-y = 90;
        };

        "end" = {
          world = "${cfg.defaultWorld}_the_end/DIM1";
          sorting = 200;
          sky-color = "#080010";
          void-color = "#080010";
          ambient-light = 0.6;
          world-sky-light = 0;
          remove-caves-below-y = -10000;
          cave-detection-ocean-floor = -5;
        };
      };
  };

  systemd.services."render-bluemap-maps" = lib.mkForce {
    serviceConfig = {
      Type = "oneshot";
      Group = "nginx";
      UMask = "026";
    };
    script = ''
      ${lib.getExe pkgs.bluemap} -c ${configFolder} -gs -r
    '';
  };

  services.nginx.virtualHosts."mc.rappet.xyz" = {
    forceSSL = true;
    sslCertificate = "/var/lib/acme/rappet.xyz/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/rappet.xyz/key.pem";
  };
}
