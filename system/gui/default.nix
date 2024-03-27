{ config, lib, pkgs, ... }:

{
  imports = [
    ./x11.nix
    ./fonts.nix
  ];
}
