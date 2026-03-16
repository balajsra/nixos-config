{ pkgs, ... }:

{
  # https://nixos.wiki/wiki/Thunar
  home.packages = with pkgs; [
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-vcs-plugin
    thunar-volman
    p7zip
    tumbler
    xarchiver
  ];
}
