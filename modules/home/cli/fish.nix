{
  pkgs,
  vars,
  config,
  ...
}:
let
  dotfilesPath = "${config.home.homeDirectory}/.config/nixos/dotfiles";
in
{
  # https://nixos.wiki/wiki/Fish
  programs.fish.enable = true;
  xdg.configFile."fish".enable = false;

  xdg.configFile."fish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish";

  # https://wiki.nixos.org/wiki/Starship
  programs.starship.enable = true;

  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/starship/.config/starship.toml";

  home.packages = with pkgs; [
    krabby
  ];
}
