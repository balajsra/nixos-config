{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.lightdm ];
  services.xserver.displayManager = {
    lightdm.enable = true;
  };
}
