{
  inputs,
  config,
  pkgs,
  ...
}:
let
  dotfilesPath = "${config.home.homeDirectory}/.config/nixos/dotfiles";
in
{
  home.packages = with pkgs; [
    swaylock-effects
    swayidle
  ];

  xdg.configFile."swaylock".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/swaylock/.config/swaylock";
  xdg.configFile."swayidle".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/swayidle/.config/swayidle";
}
