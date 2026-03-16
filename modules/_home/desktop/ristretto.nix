{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ristretto
  ];
}
