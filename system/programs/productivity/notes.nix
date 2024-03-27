{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    anytype
    logseq
  ];
}
