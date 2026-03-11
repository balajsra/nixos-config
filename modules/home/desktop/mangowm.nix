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
  imports = [
    inputs.mangowm.hmModules.mango
  ];

  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;
  };

  xdg.configFile."mango".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/mangowc/.config/mango";
}
