{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fladder
  ];
}
