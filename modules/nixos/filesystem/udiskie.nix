{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    udiskie
    udisks
  ];
}
