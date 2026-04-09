{ self, config, ... }:

{
  flake.homeModules.comms =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        beeper
        signal-desktop
        zoom-us
      ];

      home.file.".themes/dracula-beeper".source =
        config.lib.file.mkOutOfStoreSymlink "${config.primaryUser.dotfilesPath}/beeper/.themes/dracula-beeper";
    };
}
