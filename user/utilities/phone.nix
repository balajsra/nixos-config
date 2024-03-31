{ config, lib, pkgs, systemSettings, ... }:

{
  programs.kdeconnect = {
    enable = true;
    package = (if systemSettings.desktop == "gnome"
               then pkgs.gnomeExtensions.gsconnect
               else pkgs.libsForQt5.kdeconnect-kde);
  };
}
