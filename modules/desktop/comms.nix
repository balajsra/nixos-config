{ self, config, ... }:

{
  flake.homeModules.comms =
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
      config = lib.mkIf osConfig.features.comms.enable {
        home.packages = with pkgs; [
          beeper
          signal-desktop
          zoom-us
        ];

        xdg.configFile."BeeperTexts/custom.css".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/beeper/.themes/dracula-beeper/custom.css";
      };
    };
}
