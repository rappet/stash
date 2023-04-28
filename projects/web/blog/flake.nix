{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        rec {
          packages.blog = pkgs.stdenv.mkDerivation {
            name = "rappets-blog";
            src = ./.;
            installPhase = ''
              ${pkgs.hugo}/bin/hugo
              mkdir $out
              mv public/* $out/
            '';
          };
          packages.default = packages.blog;

          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
