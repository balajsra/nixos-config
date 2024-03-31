{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    starship
    krabby
  ]);
}
