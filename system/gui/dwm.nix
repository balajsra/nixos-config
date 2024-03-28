{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
    ./lightdm.nix
    ./x11.nix
  ];

  services.xserver.windowManager.dwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+dwm";
}
