let
  # x230 = "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaihkdt1hqwygxouny4ylsnk5hgc+wdz3q2xye8y05ds3+";
  ibook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMz+WvOHfl9Er2QIdQsP/z4Qifk8uj75RfNpVa2WVDr";
  katze = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5JIcEqbIaq/pBCbaU1AV3V2Mor1ZdgKoO3O9vJqW4f";
  ibook-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6LcV2AdljIQBFYWE7tRUvEfTfbNqFM3J5N8cmz50Z";
  framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyGxZI3l3PBv+zO6ZxgfP1hiMiQWwNevVtgfuUeBFDI";
  users = [
    ibook
    katze
    ibook-nixos
    framework
  ];

  services = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiBQs4tZGKGXPkc/HmpazTl5LrB8O+ka1Eao446/FOD";
  thinkcentre = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMaBGPHgYp8MA0f9PPElL/z4NiWKIgHqjO9ZQ3pgOUdu";
  fra1-de = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJh1UtgpBvgElcJCuVNU5ykvV9LpAnlTRz3/h7E4IJn";
  apu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBzD51JF2jiKhpZlJDY8ptJQk6wSE7q51t+0qeTEBAg";
  servers = [
    services
    thinkcentre
    fra1-de
    apu
  ];
in
{
  "murmur-env.age".publicKeys = users ++ [ services ];
  "nitter-auth.age".publicKeys = users ++ [ services ];
  "apu-dyndns-password.age".publicKeys = users ++ [ apu ];
  "hedgedoc-env.age".publicKeys = users ++ [ services ];
  "etebase-django-secret.age".publicKeys = users ++ [ services ];
  "mqtt-shelly-auth.age".publicKeys = users ++ [ services ];
  "mqtt-monitor.age".publicKeys = users ++ [ services ];
  "mqtt-zigbee.age".publicKeys = users ++ [ services ];
  "smb-media.age".publicKeys = users ++ servers;
  "woodpecker-env.age".publicKeys = users ++ [ services ];
  "letsencrypt-hetzner.age".publicKeys = users ++ servers;
  "transmission.age".publicKeys = users ++ servers;
  "restic-backup-password.age".publicKeys = users ++ servers;
  "garage-env.age".publicKeys = users ++ servers;
  "mastodon-env.age".publicKeys = users ++ [ services ];

  "authelia-hmac-secret.age".publicKeys = users ++ [ services ];
  "authelia-jwks.age".publicKeys = users ++ [ services ];
  "authelia-jwt-secret.age".publicKeys = users ++ [ services ];
  "authelia-session-secret.age".publicKeys = users ++ [ services ];
  "authelia-storage-secret.age".publicKeys = users ++ [ services ];
}
