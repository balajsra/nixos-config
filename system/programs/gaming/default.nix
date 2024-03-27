{ config, lib, pkgs, ... }:

{
  imports = [
    ./utilities.nix
    ./launchers.nix
    ./compatibility.nix
  ];
}
