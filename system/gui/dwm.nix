{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
    ./lightdm.nix
    ./x11.nix
  ];

  services.xserver.windowManager.dwm = {
    enable = true;
    package = pkgs.dwm.overrideAttrs {
      src = /home/sravan/.config/dwm-flexipatch;
      buildInputs = with pkgs; [
        xorg.libX11.dev
        xorg.libXinerama
        xorg.libXft
        xorg.libxcb
        xorg.xcbutil
        yajl
        jsoncpp
      ];
    };
  };

  services.xserver.displayManager.defaultSession = "none+dwm";
}
