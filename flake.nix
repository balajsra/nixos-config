{
    description = "Flake of Sravan's NixOS";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        disko = {
            url = "github:nix-community/disko/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager, disko, ... }@inputs:
    let
        hostname = "nixos";
        architecture = "x86_64-linux";
        username = "sravan";
    in
    {
        nixosConfigurations."${hostname}" = nixpkgs.lib.nixosSystem {
            system = "${architecture}";
            specialArgs = { inherit inputs; };
            modules = [
                disko.nixosModules.disko
                ./configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users."${username}" = import ./home.nix;
                        backupFileExtension = "backup";
                    };
                }
            ];
        };
    };
}
