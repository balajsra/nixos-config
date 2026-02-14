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
        vars = {
            osDisks = [ "/dev/sdb" "/dev/sda" ];
            swapSize = "2G";
            name = "Sravan Balaji";
            email = "sr98vn@gmail.com";
            username = "sravan";
            hostName = "nixos";
            architecture = "x86_64-linux";
            timeZone = "America/New_York";
        };
    in
    {
        nixosConfigurations."${vars.hostName}" = nixpkgs.lib.nixosSystem {
            system = "${vars.architecture}";
            specialArgs = { inherit inputs vars; };
            modules = [
                disko.nixosModules.disko
                ./configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        extraSpecialArgs = { inherit inputs vars; };
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        users."${vars.username}" = import ./home.nix;
                        backupFileExtension = "backup";
                    };
                }
            ];
        };
    };
}
