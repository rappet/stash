{
  config,
  lib,
  pkgs,
  ...
}:
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
}
