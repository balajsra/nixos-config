{ inputs, ... }:

{
  flake.nixosModules.home-manager = {
    imports = [
      # import official home-manager NixOS module
      inputs.home-manager.nixosModules.default
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
