{
  config,
  pkgs,
  ...
}:
let
  dotfilesPath = "${config.home.homeDirectory}/.config/nixos/dotfiles";
in
{
  # https://wiki.nixos.org/wiki/Tmux
  programs.tmux.enable = true;

  home.file.".tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.tmux";

  home.file.".tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.tmux.conf";
}
