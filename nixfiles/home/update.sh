#!/bin/sh
set -xe

nix flake update
nix run nixpkgs#home-manager -- switch --flake ~/stash/nixfiles/home
git add flake.lock
git commit -m "home: Update flake"
