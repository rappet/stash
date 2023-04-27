{
  description = "TODO";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec
        {
          packages.rust-cli-template = pkgs.callPackage ./default.nix { };

          legacyPackages = packages;

          defaultPackage = packages.rust-cli-template;

          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              libiconv
            ];
          };

          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
