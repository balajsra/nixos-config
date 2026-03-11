{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    plymouth
    plymouth-matrix-theme
  ];
}
