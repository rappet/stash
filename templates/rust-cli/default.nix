{ pkgs ? import <nixpkgs> { }
, lib
, stdenv ? pkgs.stdenv
  # A set providing `buildRustPackage :: attrsets -> derivation`
, rustPlatform ? pkgs.rustPlatform
, fetchFromGitHub ? pkgs.fetchFromGitHub
, pkgconfig ? pkgs.pkgconfig
, installShellFiles ? pkgs.installShellFiles
, libiconv
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-cli-template";
  version = "0.0.1";

  src = ./.;
  cargoSha256 = "sha256-FKb031OtkQjdXxZ+nRnmshnJspsMecOEgjK5FrtBuXM=";

  nativeBuildInputs = [ pkgconfig installShellFiles ];

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv ];

  postInstall = ''
    installManPage man/${pname}.1
  '';

  meta = with lib; {
    homepage = "";
    description = "Sample flake repository for a Rust application";
    license = licenses.mit;
  };
}
