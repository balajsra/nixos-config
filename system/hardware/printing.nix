{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.cups
    pkgs.cups-filters
    pkgs.avahi
  ];
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;
}
