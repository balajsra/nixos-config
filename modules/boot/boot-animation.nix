{ self, ... }:

{
  flake.nixosModules.boot-animation =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.featureOptions.boot.plymouth;
    in
    {
      # https://wiki.nixos.org/wiki/Plymouth
      options.featureOptions.boot.plymouth.enable = lib.mkEnableOption "Plymouth Boot Animation";

      config = lib.mkIf cfg.enable {
        boot = {
          plymouth = {
            enable = true;
            theme = "lone";
            themePackages = with pkgs; [
              (adi1090x-plymouth-themes.override {
                selected_themes = [ "lone" ];
              })
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
