{ config, lib, pkgs, ... }:

{
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    corefonts
    ubuntu_font_family
    font-awesome
    nerdfonts
    noto-fonts-color-emoji
    powerline
    ipafont
    baekmuk-ttf
    nerdfonts
  ];
}
