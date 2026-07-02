{ self, ... }:

{
  flake.nixosModules.power =
    { ... }:
    {
      imports = [
        self.nixosModules.power-keys
        self.nixosModules.lid-switch
        self.nixosModules.wakeup-triggers
        self.nixosModules.thermald
      ];
    };

  flake.nixosModules.power-keys =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.power.handle-power-keys.enable) {
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
      config = lib.mkIf (config.features.hardware.power.ignore-lid-switch.enable) {
        # https://wiki.nixos.org/wiki/Systemd/logind
        services.logind.settings.Login = {
          # Ignore lid switch detections which may cause laptop to randomly suspend
          HandleLidSwitch = "ignore";
          HandleLidSwitchExternalPower = "ignore";
          HandleLidSwitchDocked = "ignore";
        };
      };
    };

  flake.nixosModules.wakeup-triggers =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.power.disable-wakeup-triggers.enable) {
        # https://wiki.nixos.org/wiki/Power_Management
        services.udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
        '';
      };
    };

  flake.nixosModules.thermald =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.power.thermald.enable) {
        # https://wiki.nixos.org/wiki/Laptop#thermald
        services.thermald.enable = true;
      };
    };
}
