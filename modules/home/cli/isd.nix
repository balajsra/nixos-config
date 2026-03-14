{ pkgs, ... }:

{
  home.packages = with pkgs; [
    isd
  ];
}
