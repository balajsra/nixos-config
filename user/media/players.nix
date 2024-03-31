{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    gnome.eog
    mpv
    trackma-gtk
    pocket-casts
    spotify
    spicetify-cli
    ani-cli
    mangal
    calibre
  ]);
}
