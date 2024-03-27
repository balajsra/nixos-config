{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    prusa-slicer
  ]);
}
