{ config, pkgs, ... }:

{
  imports = [
    ./geoclue.nix
  ];

  # "https://wiki.nixos.org/wiki/UWSM"
  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      mangowm = {
        prettyName = "Mango";
        comment = "Mango Wayland Compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/mango";
      };
    };
  };

  programs.mango.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    };
  };

  # https://wiki.nixos.org/wiki/Polkit
  security.polkit.enable = true;
  security.soteria.enable = true;

  environment.systemPackages = with pkgs; [
    wlr-randr
    wdisplays
    shikane
    nwg-look
    kdePackages.qt6ct
    kdePackages.qtstyleplugin-kvantum
    breeze-hacked-cursor-theme
    papirus-icon-theme
    waypaper
    swww
    blueman
  ];
}
