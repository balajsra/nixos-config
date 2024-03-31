{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qalculate-gtk
    octave
  ];
}
