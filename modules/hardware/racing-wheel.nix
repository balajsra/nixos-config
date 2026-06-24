{ self, ... }:

{
  flake.nixosModules.racing-wheel =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.hardware.racing-wheel.enable) {
        environment.systemPackages = with pkgs; [
          oversteer
        ];

        hardware.new-lg4ff.enable = config.features.hardware.racing-wheel.logitech.enable;
      };
    };
}
