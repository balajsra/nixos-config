{ config, lib, pkgs, ... }:

{
  imports = [
    ./x11.nix
    ./lightdm.nix
    ../app/terminal/kitty.nix
    ../app/launcher/dmenu.nix
    ../app/launcher/rofi.nix
  ];

  services.xserver.windowManager.dwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+dwm";
}
