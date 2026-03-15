{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libqalculate
    qalculate-gtk
  ];
}
