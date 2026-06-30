{ self, ... }:

{
  flake.nixosModules.sound =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      config = lib.mkIf (config.features.hardware.sound.enable) {
        services.pipewire = {
          enable = true;
          pulse.enable = true;
        };
      };
    };
}
