{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.dmenu ];
}
