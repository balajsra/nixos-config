{ config, lib, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./automount.nix
    ./bluetooth.nix
    ./kernel.nix
    ./opengl.nix
    ./openrgb.nix
    ./printing.nix
  ];
}
