{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    mangohud
    goverlay
    vkbasalt
    gamescope
  ]);
}
