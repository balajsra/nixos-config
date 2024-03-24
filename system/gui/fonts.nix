{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    powerline
    font-awesome
    ubuntu_font_family
  ];
}
