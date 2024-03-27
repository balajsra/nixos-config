{ config, lib, pkgs, ... }:

{
  programs.gamemode = {
    enable = true;
    # settings = {};
    # enableRenice = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
    goverlay
    vkbasalt
  ];
}
