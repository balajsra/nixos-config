{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.firewalld
    pkgs.firewalld-gui
  ];
  networking.firewall.enable = true;
}
