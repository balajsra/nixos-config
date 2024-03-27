{ config, lib, pkgs, ... }:

{
  imports = [
    ./dmenu.nix
    ./rofi.nix
  ];
}
