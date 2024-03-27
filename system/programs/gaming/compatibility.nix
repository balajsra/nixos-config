{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wine
    protonup-qt
  ];
}
