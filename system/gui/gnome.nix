{ config, lib, pkgs, systemSettings, ... }:

{
  imports = [
    ./default.nix
  ];

  services.xserver = {
    displayManager.gdm = {
      enable = true;
      wayland = (if systemSettings.desktopType == "x11" then false else true);
    };

    desktopManager.gnome.enable = true;
  };
}
