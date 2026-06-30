{ self, config, ... }:

{
  flake.homeModules.comms = {
    imports = [
      self.homeModules.beeper
      self.homeModules.signal
      self.homeModules.zoom
    ];
  };

  flake.homeModules.beeper =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.comms.beeper.enable) {
        home.packages = with pkgs; [
          beeper
        ];

        xdg.configFile."BeeperTexts/custom.css".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/beeper/.themes/dracula-beeper/custom.css";
      };
    };

  flake.homeModules.signal =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.comms.signal.enable) {
        home.packages = with pkgs; [
          signal-desktop
        ];
      };
    };

  flake.homeModules.zoom =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.comms.zoom.enable) {
        home.packages = with pkgs; [
          zoom-us
        ];
      };
    };
}
