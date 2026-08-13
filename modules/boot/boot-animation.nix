{ self, ... }:

{
  flake.nixosModules.boot-animation =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      # https://wiki.nixos.org/wiki/Plymouth
      config = lib.mkIf (config.features.boot.plymouth.enable) {
        boot = {
          plymouth = {
            enable = true;
            theme = "fallout";
            themePackages = with pkgs; [
              fallout-plymouth-theme
            ];
          };

          # Enable "silent boot"
          consoleLogLevel = 3;
          initrd.verbose = false;
          kernelParams = [
            "quiet"
            "udev.log_level=3"
            "systemd.show_status=auto"
          ];
        };
      };
    };
}
