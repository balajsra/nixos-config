{ config, lib, pkgs, ... }:

{
  imports = [
    ./dbus.nix
    ./gnome-keyring.nix
  ];
}
