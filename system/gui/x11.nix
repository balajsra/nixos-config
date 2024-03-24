{ config, lib, pkgs, ... }:

{
  imports = [
    ../util/dbus.nix
    ../util/gnome-keyring.nix
    ./fonts.nix
  ];

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    xkbOptions = "";
  };
}
