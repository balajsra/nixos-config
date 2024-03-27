{ config, lib, pkgs, ... }:

{
  imports = [
    ./office.nix
    ./finance.nix
    ./notes.nix
    ./communication.nix
  ];
}
