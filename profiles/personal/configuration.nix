# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, systemSettings, userSettings, ... }:

{
  imports = [
    (../../hosts + "/${systemSettings.hwConfig}.nix")
    (../../system/gui + "/${systemSettings.desktop}.nix")
    ../../system/hardware/default.nix
    ../../system/security/default.nix
    ../../system/utilities/default.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    initrd.enable = true;
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = true;
        efiInstallAsRemovable = true;
      };
    };
  };

  networking = {
    hostName = systemSettings.hostname;
    networkmanager.enable = true;
  };

  time.timeZone = systemSettings.timezone;
  i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;
  };

  users.groups.${userSettings.username} = {
    name = userSettings.username;
    gid = 1000;
  };

  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "${userSettings.username}" "networkmanager" "wheel" "input" "dialout" ];
    packages = [];
    uid = 1000;
  };

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal
  #     pkgs.xdg-desktop-portal-gtk
  #   ];
  #   config.common.default = [ "gtk" ];
  # };

  # The first version of NixOS installed on this particular machine
  # Is used to maintain compatibility with application data
  # (e.g., databases) created on older NixOS version
  system.stateVersion = "23.11";
}
