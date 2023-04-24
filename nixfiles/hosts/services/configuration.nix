{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  networking.hostName = "services";
  networking.domain = "rappet.xyz";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMz+WvOHfl9Er2QIdQsP/z4Qifk8uj75RfNpVa2WVDr rappet@MacBook-Air-von-Raphael.local" 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5JIcEqbIaq/pBCbaU1AV3V2Mor1ZdgKoO3O9vJqW4f rappet@katze" 
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZGkHoe235ue1fUvy8XjGStLLwTcFllFJ3hStKj9ahT rappet@x230.rappet.de" 
  ];
  security.sudo.wheelNeedsPassword = false;
}
