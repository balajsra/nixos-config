{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prusa-slicer
  ];
}
