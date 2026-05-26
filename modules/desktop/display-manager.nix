{ self, ... }:

{
  flake.nixosModules.display-manager = {
    imports = [
      self.nixosModules.gdm
      self.nixosModules.greetd
    ];
  };

  flake.nixosModules.gdm =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.display-manager == "gdm") {
        services.displayManager.gdm.enable = true;
      };
    };

  flake.nixosModules.greetd =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.display-manager == "greetd") {
        # https://nixos.wiki/wiki/Greetd
        # https://ryjelsum.me/homelab/greetd-session-choose/
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions ${config.services.xserver.displayManager.sessionData.desktops}/share/xsessions:${config.services.xserver.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
              user = "greeter";
            };
          };
        };
      };
    };
}
