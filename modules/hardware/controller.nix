{ self, ... }:

{
  flake.nixosModules.controller = {
    imports = [
      self.nixosModules.xbox
      self.nixosModules.racing-wheel
    ];
  };

  flake.nixosModules.xbox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.hardware.controller.xbox.enable) {
        hardware.xpadneo.enable = true;
      };
    };

  flake.nixosModules.racing-wheel =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.hardware.controller.racing-wheel.enable) {
        environment.systemPackages = with pkgs; [
          oversteer
        ];

        hardware.new-lg4ff.enable = config.features.hardware.controller.racing-wheel.logitech.enable;
      };
    };
}
