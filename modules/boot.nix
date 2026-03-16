{ self, ... }:

{
  flake.nixosModules.boot-grub-luks-btrfs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.featureOptions.boot.grub-luks-btrfs;
    in
    {
      options.featureOptions.boot.grub-luks-btrfs.enable =
        lib.mkEnableOption "GRUB with LUKS and BTRFS support";

      config = lib.mkIf cfg.enable {
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
