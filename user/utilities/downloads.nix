{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qbittorrent-qt5
  ];
}
