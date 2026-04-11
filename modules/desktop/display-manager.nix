{ self, ... }:

{
  flake.nixosModules.display-manager = {
    services.displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };
}
