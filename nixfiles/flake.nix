{
  description = "rappet's NixOS/nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    rappet-xyz.url = "github:rappet/stash?dir=projects/web/rappet-xyz";

    tlslb.url = "github:rappet/tlslb";
    tlslb.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    with inputs;
    {
      nixosConfigurations =
        let
          baseModules = [
            agenix.nixosModules.default
            disko.nixosModules.disko
            tlslb.nixosModules.tlslb
          ];
        in
        {
          "services" = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = baseModules ++ [
              ./modules/reverse-proxy.nix
              ./hosts/services/configuration.nix
            ];
            specialArgs = {
              system = "aarch64-linux";
              inputs = inputs;
            };
          };
          "thinkcentre" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = baseModules ++ [
              ./modules/reverse-proxy.nix
              ./hosts/thinkcentre/configuration.nix
              ./hosts/thinkcentre/hardware-configuration.nix
            ];
            specialArgs = {
              system = "x86_64-linux";
              inputs = inputs;
            };
          };
          "fra1-de" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = baseModules ++ [
              ./modules/reverse-proxy.nix
              ./hosts/fra1-de/configuration.nix
            ];
            specialArgs = {
              system = "x86_64-linux";
              inputs = inputs;
            };
          };
          "apu" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = baseModules ++ [
              ./hosts/apu/configuration.nix
              ./hosts/apu/hardware-configuration.nix
            ];
            specialArgs = {
              system = "x86_64-linux";
              inputs = inputs;
            };
          };
        };

      deploy.nodes = {
        services = {
          hostname = "services.rappet.xyz";
          profiles.system = {
            sshUser = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.services;
            remoteBuild = true;
          };
        };
        thinkcentre = {
          hostname = "thinkcentre";
          profiles.system = {
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.thinkcentre;
            remoteBuild = true;
          };
        };
        fra1-de = {
          hostname = "193.148.249.188";
          profiles.system = {
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.fra1-de;
            remoteBuild = true;
          };
        };
        apu = {
          hostname = "192.168.188.39";
          profile.system = {
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.apu;
            remoteBuild = true;
          };
        };
      };

      #checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    });
}
