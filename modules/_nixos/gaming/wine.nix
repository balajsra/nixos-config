{ pkgs, ... }:

{
  # https://wiki.nixos.org/wiki/Wine
  environment.systemPackages = with pkgs; [
    wineWow64Packages.stable
    winetricks
    protonplus
    protontricks
  ];
}
