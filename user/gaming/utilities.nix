{ config, lib, pkgs, ... }:

{
  programs.gamemode = {
    enable = true;
    # settings = {};
    # enableRenice = true;
  };

  home.packages = (with pkgs; [
    mangohud
    goverlay
    vkbasalt
  ]);
}
