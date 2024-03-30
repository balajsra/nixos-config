{ config, lib, pkgs, userSettings, ... }:

{
  imports = [
    ./default.nix
    ./lightdm.nix
    ./x11.nix
  ];

  services.xserver.windowManager.awesome = {
    enable = true;
    luaModules = with pkgs.luaPackages; [
      luarocks
      luadbi-mysql
    ];
  };

  services.xserver.displayManager.defaultSession = "none+awesome";
}
