{ config, pkgs, ... }:

{
  programs.mango.enable = true;

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];
}
