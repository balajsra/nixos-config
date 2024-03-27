{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    wine
    protonup-qt
  ]);
}
