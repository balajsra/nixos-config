{ self, inputs, ... }:

{
  flake.nixosModules.display-manager = {
    imports = [
      self.nixosModules.gdm
      self.nixosModules.greetd
      self.nixosModules.dank-greeter
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
        # https://wiki.nixos.org/wiki/Greetd
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

  flake.nixosModules.dank-greeter =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      imports = [
        inputs.dank-greeter.nixosModules.default
      ];

      config = lib.mkIf (config.features.display-manager == "dank-greeter") {
        # https://danklinux.com/docs/dankgreeter/nixos-flake#configuration-options
        programs.dms-greeter = {
          enable = true;
          package = inputs.dank-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default;
          compositor.name = config.features.desktop-environment;

          # Sync user's DankMaterialShell theme with the greeter
          configHome = "/home/${config.primaryUser.username}";

          logs = {
            save = true;
            path = "/tmp/dms-greeter.log";
          };
        };

        # Ensure state and cache directories exist with correct ownership
        systemd.tmpfiles.rules = [
          "d /var/lib/dms-greeter 0755 greeter greeter -"
          "d /var/cache/dms-greeter 0755 greeter greeter -"
        ];
      };
    };
}
