{ self, config, ... }:
let
  dotfilesPath = "${config.home.homeDirectory}/.config/nixos/dotfiles";
in
{
  flake.homeModules.comms =
    { pkgs, ... }:
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
