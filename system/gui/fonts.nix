{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    corefonts
    powerline
    font-awesome
    ubuntu_font_family
  ];
}
