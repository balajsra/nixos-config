{ config, lib, pkgs, ... }:

{
  imports = [
    ./dbus.nix
    ./gnome-keyring.nix
    ./miscellaneous.nix
    ./gaming.nix
    ./backups.nix
    ./user-shell.nix
    ./samba.nix
    ./cloud.nix
    ./phone.nix
  ];
}
