{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    beeper
    discord
    signal-desktop
    zoom-us
  ];
}
