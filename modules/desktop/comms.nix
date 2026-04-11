{ self, config, ... }:

{
  flake.homeModules.comms =
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
      home.packages = with pkgs; [
        beeper
        signal-desktop
        zoom-us
      ];

      home.file.".themes/dracula-beeper".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/beeper/.themes/dracula-beeper";
    };
}
