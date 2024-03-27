{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    anytype
    logseq
  ]);
}
