{ self, ... }:

{
  flake.nixosModules.bluetooth =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      config = lib.mkIf (config.features.hardware.bluetooth.enable) {
        hardware.bluetooth.enable = true;
      };
    };
}
