{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ventoy
  ];
}
