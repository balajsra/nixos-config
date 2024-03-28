{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
    ./lightdm.nix
    ./x11.nix
  ];

  nixpkgs = {
    overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs (oldattrs: {
          src = /home/sravan/.config/dwm-flexipatch;
          buildInputs = with pkgs; [
            xorg.libX11
            xorg.libXinerama
            xorg.libXft
            xorg.libxcb
            xorg.xcbutil
            yajl
            jsoncpp
          ];
        });
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    polybar
  ];

  services.xserver.windowManager.dwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+dwm";
}
