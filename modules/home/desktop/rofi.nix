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
  # https://wiki.nixos.org/wiki/Rofi
  programs.rofi = {
    enable = false;
  };
  home.packages = with pkgs; [
    rofi
  ];

  xdg.configFile."rofi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
}
