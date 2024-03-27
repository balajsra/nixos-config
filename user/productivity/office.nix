{ config, lib, pkgs, ... }:

{
  home.packages = (with pkgs; [
    onlyoffice-bin
    xournalpp
    zathura
    libsForQt5.okular
  ]);
}
