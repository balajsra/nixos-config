{ config, lib, pkgs, userSettings, ... }:

{
  imports = [
    ./default.nix
    (if userSettings.desktopType == "x11" then ./x11.nix else "")
  ];

  services.xserver.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = (if userSettings.desktopType == "x11" then false else true);
    defaultSession = (if userSettings.desktopType == "x11" then "plasmax11" else "plasma");
  };
  services.desktopManager.plasma6.enable = true;
}
