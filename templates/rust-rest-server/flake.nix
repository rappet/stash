{
  description = "TODO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages.rust-rest-server-template = pkgs.callPackage ./default.nix { };

        legacyPackages = packages;

        defaultPackage = packages.rust-rest-server-template;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            libiconv
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
