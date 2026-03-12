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
    ./dunst.nix
    ./rofi.nix
    ./swaylock.nix
    inputs.mangowm.hmModules.mango
  ];

  wayland.windowManager.mango = {
    enable = true;
    # Disable systemd integration since it conflicts with UWSM
    systemd.enable = false;
  };

  xdg.configFile."mango".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/mangowc/.config/mango";
}
