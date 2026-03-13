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
    ./gammastep.nix
    ./rofi.nix
    ./swappy.nix
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

  # https://wiki.nixos.org/wiki/Waybar
  programs.waybar.enable = true;

  xdg.configFile."waybar".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/mango/.config/mango/waybar";
}
