{ config, lib, pkgs, systemSettings, ... }:

{
  imports = [
    ./default.nix
    (if systemSettings.desktopType == "x11" then ./x11.nix else "")
  ];

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = (if systemSettings.desktopType == "x11" then false else true);
  };
  services.xserver.desktopManager.gnome.enable = true;
}
