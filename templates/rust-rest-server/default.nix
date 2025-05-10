{
  pkgs ? import <nixpkgs> { },
  lib,
  stdenv ? pkgs.stdenv,
  # A set providing `buildRustPackage :: attrsets -> derivation`
  rustPlatform ? pkgs.rustPlatform,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  pkg-config ? pkgs.pkg-config,
  installShellFiles ? pkgs.installShellFiles,
  libiconv,
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-rest-server-template";
  version = "0.0.1";

  src = ./.;
  cargoHash = "sha256-MBxsT9Ec+ovR/OK2vxNlQTquSoR5FZ46aMeBpdYhH4M=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

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
