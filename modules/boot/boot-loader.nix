{ self, ... }:

{
  flake.nixosModules.boot-loader =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf config.features.boot.grub-luks-btrfs.enable {
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
          systemd.enable = true;
          services.lvm.enable = true;
          supportedFilesystems = [ "btrfs" ];
          availableKernelModules = [
            "aesni_intel"
            "cryptd"
            "dm_mod"
            "dm_crypt"
          ];
        };
      };
    };
}
