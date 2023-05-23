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
          lib = nixpkgs.lib;
          apple_pkgs =
            if pkgs.stdenv.isDarwin then with pkgs.darwin.apple_sdk.frameworks; [
              Cocoa
              MetalKit
            ] else with pkgs; [
              alsa-lib
              wayland
              wayland-protocols
              libxkbcommon
              xorg.libX11
              xorg.libXcursor
              xorg.libXrandr
              xorg.libXi
              libjack2
            ];
        in
        {
          devShells.default = pkgs.mkShell rec {
            buildInputs = with pkgs; [
              libiconv
              cargo
              rustc
              rust-analyzer
              pkgconfig
            ] ++ apple_pkgs;
            LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
          };
        }
        );
}
