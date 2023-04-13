# home .dotfiles etc.

First install nix + enable flake support.

To update everything:

```shell
nix run nixpkgs#home-manager -- --flake /Users/rappet/stash/nixfiles/home switch
```
