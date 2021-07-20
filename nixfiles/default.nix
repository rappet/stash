let
  pkgs = import <nixpkgs> {};
  hook = ''
  eval "$(starship init bash)"
  '';
in
pkgs.mkShell {
  buildInputs = [
    pkgs.hello

    pkgs.which
    pkgs.htop
    pkgs.zlib
    pkgs.bgpq4
    pkgs.mtr
    pkgs.starship
    pkgs.cargo
    pkgs.python3
    pkgs.fish
    pkgs.fd
    pkgs.neovim
    pkgs.home-manager

    # keep this line if you use bash
    pkgs.bashInteractive
  ];
  shellHook = hook;
}
