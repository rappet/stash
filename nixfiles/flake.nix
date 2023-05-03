{
  description = "rappet's NixOS/nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    blog.url = "path:../projects/web/blog";
  };

  outputs = inputs: with inputs; {
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
          agenix.nixosModules.default
        ];
        specialArgs = { system = "x86_64-linux"; };
      };

      "x230" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/x230/configuration.nix
          agenix.nixosModules.default
        ];
        specialArgs = { system = "x86_64-linux"; };
      };

      "services" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./hosts/services/configuration.nix
          agenix.nixosModules.default
        ];
        specialArgs = { system = "aarch64-linux"; blog = blog; };
      };

      "apu" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/apu/configuration.nix
          agenix.nixosModules.default
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
        hostname = "apu.rappet.xyz";
        profiles.system = {
          sshUser = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.apu;
          remoteBuild = true;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  } // flake-utils.lib.eachDefaultSystem (system: {
    formatter = nixpkgs-darwin.legacyPackages.${system}.nixpkgs-fmt;
  });
}
