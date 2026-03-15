{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pocket-casts
  ];
}
