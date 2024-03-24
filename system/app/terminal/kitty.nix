{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kitty ];
}
