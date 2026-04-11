{ self, config, ... }:

{
  flake.nixosModules.night-light = {
    services.geoclue2 = {
      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };

      appConfig.gammastep-indicator = {
        isAllowed = true;
        isSystem = false;
      };
    };
  };

  flake.homeModules.night-light =
    {
      pkgs,
      config,
      osConfig,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      # https://nixos.wiki/wiki/Gammastep
      services.gammastep = {
        enable = true;
        tray = true;
        provider = "geoclue2";
        temperature.day = 6500;
        temperature.night = 3500;
        settings = {
          general = {
            fade = 1;
            adjustment-method = "wayland";
          };
        };
      };

      home.file.".scripts/gammastep.sh".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/gammastep/.scripts/gammastep.sh";
    };
}
