{ self, ... }:

{
  flake.nixosModules.display-manager = {
    imports = [
      self.nixosModules.gdm
      self.nixosModules.greetd
      self.nixosModules.dms-greeter
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
              command = "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
              user = "${config.primaryUser.username}";
            };
          };
        };
      };
    };

  flake.nixosModules.dms-greeter =
    {
      options,
      pkgs,
      config,
      lib,
      ...
    }:
    let
      compositor = config.features.desktop-environment;
    in
    {
      # Default module only supports niri, hyprland, and sway. This overrides the enum values to include
      # whatever compositor was selected
      options.services.displayManager.dms-greeter.compositor.name = lib.mkOption {
        type = lib.types.enum [
          "niri"
          "hyprland"
          "sway"
          compositor
        ];
      };

      config = lib.mkIf (config.features.display-manager == "dms-greeter") {
        # https://danklinux.com/docs/dankgreeter/nixos
        services.displayManager.dms-greeter = {
          enable = true;
          compositor.name = config.features.desktop-environment;
          configHome = "/home/${config.primaryUser.username}";
          logs = {
            save = true;
            path = "/tmp/dms-greeter.log";
          };
          quickshell.package = pkgs.quickshell;
        };
      };
    };
}
