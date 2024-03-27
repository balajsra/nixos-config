{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome.eog
    mpv
    trackma-gtk
    pocket-casts
    spotify
    spicetify-cli
  ];
}
