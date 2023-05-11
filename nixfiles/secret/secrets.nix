let
  # x230 = "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaihkdt1hqwygxouny4ylsnk5hgc+wdz3q2xye8y05ds3+";
  ibook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMz+WvOHfl9Er2QIdQsP/z4Qifk8uj75RfNpVa2WVDr";
  katze = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO5JIcEqbIaq/pBCbaU1AV3V2Mor1ZdgKoO3O9vJqW4f";
  ibook-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6LcV2AdljIQBFYWE7tRUvEfTfbNqFM3J5N8cmz50Z";
  users = [ ibook katze ibook-nixos ];

  services = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7niOGmgx7tsK4zGRosgSgSNoOhgQ5pdc1zWTnLQOGM";
  apu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0DXtBKuiY0nylLoAvf65fr8VW9F0LijUIko4Q1sl9t";
  servers = [ services ];
in
{
  "murmur-env.age".publicKeys = users ++ [ services ];
  "nitter-auth.age".publicKeys = users ++ [ services ];
  "libreddit-auth.age".publicKeys = users ++ [ services ];
  "apu-dyndns-password.age".publicKeys = users ++ [ apu ];
  "hedgedoc-env.age".publicKeys = users ++ [ services ];
}
