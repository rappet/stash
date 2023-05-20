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
          apple_pkgs =
            if pkgs.stdenv.isDarwin then with pkgs.darwin.apple_sdk.frameworks; [
              Cocoa
              MetalKit
            ] else [ ];
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              libiconv
              cargo
              rustc
              rust-analyzer
            ] ++ apple_pkgs;
          };
        }
      );
}
