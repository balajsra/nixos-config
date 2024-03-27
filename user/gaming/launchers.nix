{ config, lib, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };

  home.packages = (with pkgs; [
    bottles
    lutris
    heroic
    prismlauncher
  ]);
}
