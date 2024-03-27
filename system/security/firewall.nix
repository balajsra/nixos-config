{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firewalld
    firewalld-gui
  ];
  networking.firewall.enable = true;
}
