{ self, ... }:

{
  flake.nixosModules.firmware = {
    imports = [
      self.nixosModules.fwupd
      self.nixosModules.microcode
    ];
  };

  flake.nixosModules.fwupd =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.firmware.enable) {
        # https://wiki.nixos.org/wiki/Fwupd
        services.fwupd.enable = true;

        hardware.enableAllFirmware = true;
      };
    };

  flake.nixosModules.microcode =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.firmware.enable) {
        hardware.enableRedistributableFirmware = true;
      };
    };
}
