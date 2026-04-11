{ self, ... }:

{
  flake.nixosModules.system76 =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.system76.enable) {
        # https://support.system76.com/articles/system76-software/#nixos
        hardware.system76.enableAll = true;
        services.power-profiles-daemon.enable = false;
      };
    };
}
