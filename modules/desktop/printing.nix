{ self, ... }:

{
  flake.nixosModules.printing = { config, lib, ... }: {
    config = lib.mkIf (config.features.hardware.printing.enable) {
      services.printing.enable = true;
    };
  };
}
