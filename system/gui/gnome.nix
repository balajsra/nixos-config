{ config, lib, pkgs, ... }:

{
  imports = [
    ./x11.nix
  ];

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
}
