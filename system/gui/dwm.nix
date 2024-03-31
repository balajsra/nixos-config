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

      package = (pkgs.dwm.overrideAttrs (finalAttrs: previousAttrs: {
        pname = previousAttrs.pname + "-flexipatch";
        version = "6.5";
        src = (/home + "/${userSettings.username}" + /.config/dwm-flexipatch);

        buildInputs = previousAttrs.buildInputs ++ (with pkgs; [
          xorg.libxcb
          xorg.xcbutil
          yajl
          jsoncpp
        ]);
      }));
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
    playerctl
    zscroll
    (polybar.overrideAttrs (finalAttrs: previousAttrs: {
      pname = previousAttrs.pname + "-dwm-module";
      version = "3.5.2";

      src = fetchFromGitHub {
        owner = "mihirlad55";
        repo = "polybar-dwm-module";
        rev = "0c3e139ac54e081c06ef60548927e679d80d4297";
        hash = "sha256-ZL7yDGGiZFGgVXZXS+d3xUDhOOd5lp2mo2ipFN92mIY=";
        fetchSubmodules = true;
      };

      buildInputs = previousAttrs.buildInputs ++ [
        jsoncpp
        git
        libpulseaudio
      ];

      patches = [];
    }))
  ];
}
