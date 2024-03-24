{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.blueman ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
