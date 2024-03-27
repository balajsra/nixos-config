{ config, lib, pkgs, ... }:

{
  programs.gamemode = {
    enable = true;
    # settings = {};
    # enableRenice = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };
}
