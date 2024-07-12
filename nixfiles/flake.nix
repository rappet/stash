{
  description = "rappet's NixOS/nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    blog.url = "github:rappet/stash?dir=projects/web/blog";
    blog.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: with inputs; {
    nixosConfigurations = {
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

      "fra1-de" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/fra1-de/configuration.nix
          agenix.nixosModules.default
        ];
        specialArgs = { system = "x86_64-linux"; };
      };
    };

    deploy.nodes = {
      services = {
        hostname = "services.rappet.xyz";
        sshOpts = [ "-p" "22" ];
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
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.apu;
        };
      };
      fra1-de = {
        hostname = "193.148.249.188";
        profiles.system = {
          sshUser = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.fra1-de;
        };
      };
    };

    #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  } // flake-utils.lib.eachDefaultSystem (system: {
    formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
  });
}
