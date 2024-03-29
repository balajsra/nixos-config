{ config, lib, pkgs, systemSettings, ... }:

{
  imports = [
    ./default.nix
  ];

  services.xserver.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = (if systemSettings.desktopType == "x11" then false else true);
    };

    defaultSession = (if systemSettings.desktopType == "x11" then "plasmax11" else "plasma");
  };

  services.desktopManager.plasma6.enable = true;
}
