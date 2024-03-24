{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gvfs
    pkgs.udisks
    pkgs.udiskie
  ];
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
