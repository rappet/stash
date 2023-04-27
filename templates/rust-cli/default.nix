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
  cargoSha256 = "sha256-7PDjXQIzswc59PtfTSW0XACFQ6O2wTkcQQgFRlnUauQ=";

  nativeBuildInputs = [ pkgconfig installShellFiles ];

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv ];

  postInstall = ''
    installManPage man/${pname}.1
    installShellCompletion completions/${pname}.{bash,fish}
    installShellCompletion completions/_${pname}
  '';

  meta = with lib; {
    homepage = "";
    description = "Sample flake repository for a Rust application";
    license = licenses.mit;
  };
}
