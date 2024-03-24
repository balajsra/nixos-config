{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.rofi ];
}
