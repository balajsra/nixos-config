{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    onlyoffice-bin
    xournalpp
    zathura
    libsForQt5.okular
  ];
}
