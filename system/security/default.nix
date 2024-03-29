{ config, lib, pkgs, ... }:

{
  imports = [
    ./firewall.nix
    ./gpg.nix
    ./polkit.nix
  ];
}
