{ config, lib, pkgs, ... }:

{
  imports = [
    ./players.nix
    ./editors.nix
    ./creation.nix
  ];
}
