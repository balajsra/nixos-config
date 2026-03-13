{
  config,
  pkgs,
  ...
}:
let
  dotfilesPath = "${config.home.homeDirectory}/.config/nixos/dotfiles";
in
{
  programs.foot.enable = true;

  xdg.configFile."foot".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/foot/.config/foot";
}
