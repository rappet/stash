{
  description = "Ultrasonic data transfer rust development environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          apple_pkgs = with pkgs.darwin.apple_sdk.frameworks; [
            Cocoa
            MetalKit
          ];
        in {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              libiconv
            ] ++ apple_pkgs;
          };
        }
      );
}
