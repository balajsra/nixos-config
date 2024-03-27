{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
    ./lightdm.nix
  ];

  services.xserver.windowManager.dwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+dwm";
}
