{
  description = "rappet's NixOS/nix-darwin/Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = { self, darwin, nixpkgs, nixpkgs-darwin, flake-utils }: {
    darwinConfigurations."ibook" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/ibook/darwin-configuration.nix
      ];
    };

    nixosConfigurations."katze" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/katze/configuration.nix
      ];
      specialArgs = { system = "x86_64-linux"; };
    };

    nixosConfigurations."x230" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/x230/configuration.nix
      ];
      specialArgs = { system = "x86_64-linux"; };
    };

    formatter.x86_64-linux = nixpkgs-darwin.legacyPackages.x86_64-linux.nixpkgs-fmt;
    formatter.aarch64-linux = nixpkgs-darwin.legacyPackages.aarch64-linux.nixpkgs-fmt;
    formatter.aarch64-darwin = nixpkgs-darwin.legacyPackages.aarch64-darwin.nixpkgs-fmt;
  };
}
