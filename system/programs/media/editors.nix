{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gimp
    libsForQt5.kdenlive
    ffmpeg
  ];
}
