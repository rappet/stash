{
  description = "rappet's NixOS/nix-darwin/Home Manager config";

  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager/release-22.11";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = { self, darwin, nixpkgs-darwin, home-manager-darwin }: {
    darwinConfigurations."ibook" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        home-manager-darwin.darwinModules.home-manager
        ./hosts/ibook/darwin-configuration.nix 
      ];
    };
    formatter.aarch64-darwin = nixpkgs-darwin.legacyPackages.aarch64-darwin.nixpkgs-fmt;
  };
}
