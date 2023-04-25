{
  description = "rappet's NixOS/nix-darwin/Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, darwin, nixpkgs, nixpkgs-darwin, flake-utils, deploy-rs }: {
    darwinConfigurations."ibook" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/ibook/darwin-configuration.nix
      ];
    };

    nixosConfigurations = {
      "katze" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/katze/configuration.nix
        ];
        specialArgs = { system = "x86_64-linux"; };
      };

      "x230" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/x230/configuration.nix
        ];
        specialArgs = { system = "x86_64-linux"; };
      };

      "services" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/services/configuration.nix
        ];
        specialArgs = { system = "aarch64-linux"; };
      };

      "apu" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/apu/configuration.nix
        ];
        specialArgs = { system = "x86_64-linux"; };
      };
    };

    deploy.nodes = {
      services = {
        hostname = "services.rappet.de";
        profiles.system = {
          sshUser = "root";
          path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.services;
          remoteBuild = true;
        };
      };
      apu = {
        hostname = "apu";
        profiles.system = {
          sshUser = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.services;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

    formatter.x86_64-linux = nixpkgs-darwin.legacyPackages.x86_64-linux.nixpkgs-fmt;
    formatter.aarch64-linux = nixpkgs-darwin.legacyPackages.aarch64-linux.nixpkgs-fmt;
    formatter.aarch64-darwin = nixpkgs-darwin.legacyPackages.aarch64-darwin.nixpkgs-fmt;
  };
}
