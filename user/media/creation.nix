{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    blender
    obs-studio
    freecad
    sweethome3d.application
  ]);
}
