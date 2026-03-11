{ config, pkgs, ... }:

{
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

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];
}
