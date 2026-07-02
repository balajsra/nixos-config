{ self, ... }:

{
  flake.nixosModules.system76 =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.system76.enable) {
        hardware.system76.enableAll = true;

        hardware.system76.power-daemon.enable = false;
        services.power-profiles-daemon.enable = false;
      };
    };
}
