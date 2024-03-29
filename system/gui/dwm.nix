{ config, lib, pkgs, userSettings, ... }:

{
  imports = [
    ./default.nix
  ];

  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "";
      options = "";
    };

    windowManager.dwm = {
      enable = true;

      package = pkgs.dwm.overrideAttrs {
        src = (/home + "/${userSettings.username}" + /.config/dwm-flexipatch);

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

    displayManager = {
      defaultSession = "none+dwm";
      lightdm.enable = true;
    };
  };

  services.picom.enable = true;

  environment.systemPackages = with pkgs; [
    arandr
    autorandr
    unclutter-xfixes
  ];
}
