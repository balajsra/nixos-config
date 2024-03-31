{ config, lib, pkgs, ... }:

{
  # Printing
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;

  # Scanning
  services.saned.enable = true;

  environment.systemPackages = with pkgs; [
    # HP Printer Drivers
    hplip

    # Scanner Frontend
    libsForQt5.skanlite
  ];
}
