{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
  ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
}
