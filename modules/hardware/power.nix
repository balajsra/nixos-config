{ self, ... }:

{
  flake.nixosModules.power =
    { ... }:
    {
      imports = [
        self.nixosModules.power-keys
        self.nixosModules.lid-switch
      ];
    };

  flake.nixosModules.power-keys =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.handle-power-keys.enable) {
        # https://wiki.nixos.org/wiki/Systemd/logind
        services.logind.settings.Login = {
          # Power button puts system to sleep
          HandlePowerKey = "suspend";
          # Holding power button turns off system
          HandlePowerKeyLongPress = "poweroff";
        };
      };
    };

  flake.nixosModules.lid-switch =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.ignore-lid-switch.enable) {
        # https://wiki.nixos.org/wiki/Systemd/logind
        services.logind.settings.Login = {
          # Ignore lid switch detections which may cause laptop to randomly suspend
          HandleLidSwitch = "ignore";
          HandleLidSwitchExternalPower = "ignore";
          HandleLidSwitchDocked = "ignore";
        };
      };
    };
}
