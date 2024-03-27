{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    beeper
    discord
    signal-desktop
    zoom-us
  ]);
}
