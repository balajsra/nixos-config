{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    qbittorrent-qt5
  ]);
}
