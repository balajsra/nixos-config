{
  description = "Flake of Sravan's NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    self.submodules = true;
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      mangowm,
      ...
    }@inputs:
    let
      vars = {
        name = "Sravan Balaji";
        email = "sr98vn@gmail.com";
        username = "sravan";
      };
      mkHost =
        {
          hostName,
          architecture,
          timeZone,
          osDisks,
          swapSize,
        }:
        nixpkgs.lib.nixosSystem {
          system = "${architecture}";
          specialArgs = {
            inherit
              inputs
              vars
              hostName
              architecture
              timeZone
              osDisks
              swapSize
              ;
          };
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            mangowm.nixosModules.mango
            ./hosts/${hostName}
          ];
        };
    in
    {
      nixosConfigurations = {
        # NixOS VM on Proxmox
        proxmox-nix-vm = mkHost {
          hostName = "proxmox-nix-vm";
          architecture = "x86_64-linux";
          timeZone = "America/New_York";
          osDisks = [
            "/dev/sda"
          ];
          swapSize = "2G";
        };
      };
    };
}
