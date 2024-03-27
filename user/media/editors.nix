{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    gimp
    libsForQt5.kdenlive
    ffmpeg
  ]);
}
