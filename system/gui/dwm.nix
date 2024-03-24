{ config, lib, pkgs, ... }:

{
  imports = [
    ./x11.nix
    ./lightdm.nix
    ../app/terminal/kitty.nix
    ../app/launcher/dmenu.nix
    ../app/launcher/rofi.nix
  ];

  environment.systemPackages = [ pkgs.dwm ];
  services.xserver.windowManager.dwm.enable = true;
  services.xserver.displayManager.defaultSession = "dwm";
}
