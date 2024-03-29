{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    blender
    obs-studio
    freecad
  ]);
}
