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

        # Low-level Bluetooth stability & power management tweaks
        boot.extraModprobeConfig = ''
          # Enhanced Retransmission Mode (ERTM) is a known protocl bug in Linux's Bluetooth stack for Xbox controllers
          # Without this, the controller will randomly drop its Bluetooth connection or fail to re-pair
          # automatically after going to sleep
          options bluetooth disable_ertm=1

          # Disable auto-suspending bluetooth radio
          options btusb enable_autosuspend=0
        '';

        # Environment overrides for Steam / SDL evdev passthrough
        environment.sessionVariables = {
          # Forces SDL to use standard Linux evdev instead of HIDAPI for Xbox gamepads
          SDL_JOYSTICK_HIDAPI_XBOX = "0";
          # Tells steam to disable its low-level hidraw hook for Xbox gamepads
          STEAM_DISABLE_HIDRAW_XBOX = "1";
        };
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
