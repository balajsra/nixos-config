{

  description = "My first flake!";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
      };
      username = "sravan";
      name = "Sravan Balaji";
    in {
      nixosConfigurations = {
        nixos-vm = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
          ];
          specialArgs = {
            inherit username;
            inherit name;
          };
        };
      };
    };
}
