{
  description = "rappet's home";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          legacyPackages.homeConfigurations.rappet = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./modules/neovim
              ./home.nix
            ];
          };

          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
