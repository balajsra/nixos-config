{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerdfonts
    powerline
    font-awesome
    ubuntu_font_family
  ];
}
