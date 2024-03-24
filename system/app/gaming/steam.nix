{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.steam ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };
}
