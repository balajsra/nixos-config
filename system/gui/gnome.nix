{ config, lib, pkgs, userSettings, ... }:

{
  imports = [
    ./default.nix
    (if userSettings.desktopType == "x11" then ./x11.nix else "")
  ];

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = (if userSettings.desktopType == "x11" then false else true);
  };
  services.xserver.desktopManager.gnome.enable = true;
}
