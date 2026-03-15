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
  services.dunst.enable = true;
  xdg.configFile."dunst/dunstrc".enable = false;

  xdg.configFile."dunst".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";

  home.file.".scripts/dunst.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.scripts/dunst.sh";
}
