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

      # Override dwm package with personal dwm-flexipatch config
      package = (pkgs.dwm.overrideAttrs (finalAttrs: previousAttrs: {
        pname = previousAttrs.pname + "-flexipatch";
        version = "6.5";
        src = (/home + "/${userSettings.username}" + /.config/dwm-flexipatch);

        # Add dependencies for dwmipc / polybar communication patches
        buildInputs = previousAttrs.buildInputs ++ (with pkgs; [
          # Dependencies for swallow patch
          xorg.libxcb
          xorg.xcbutil

          # Dependencies for dwm-ipc patch
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

  # Picom Compositor
  services.picom.enable = true;

  # Night Light
  services.redshift = {
    enable = true;
    package = pkgs.redshift;
    executable = "/bin/redshift-gtk";
  };
  services.geoclue2 = {
    enable = true;
  };
  location.provider = "geoclue2";

  # File Manager
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages = with pkgs; [
    # X11 Utilities
    arandr
    autorandr
    unclutter-xfixes

    # Wallpaper
    nitrogen

    # Terminal
    kitty

    # System Monitor
    btop
    qdirstat
    gnome.gnome-disk-utility

    # Media / Volume Controls
    playerctl
    pavucontrol

    # Polybar Media Module Dependency
    zscroll

    # Notification Daemon
    deadd-notification-center

    # Automounter
    udiskie

    # Power Management
    xfce.xfce4-power-manager

    # Polybar with DWM Module
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

      # Extra dependencies for dwm module
      buildInputs = previousAttrs.buildInputs ++ [
        jsoncpp
        git
        libpulseaudio
      ];

      # Remove patches applied by default polybar package
      patches = [];
    }))
  ];
}
