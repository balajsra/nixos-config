{ pkgs, ... }:

{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev"; # "nodev" is required for UEFI/EFI installs
      efiSupport = true;
      enableCryptodisk = true; # Allows GRUB to "see" encrypted partitions
    };
  };

  boot.initrd = {
    supportedFilesystems = [ "btrfs" ];
    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      "dm_mod"
      "dm_crypt"
    ];
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
