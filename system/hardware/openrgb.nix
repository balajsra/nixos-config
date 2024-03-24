{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.openrgb-with-all-plugins ];
  services.hardware.openrgb = {
    enable = true;
  };
}
