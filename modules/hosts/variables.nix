{ self, lib, ... }:

{
  flake.nixosModules.variables = {
    options = {
      storage = {
        enable = lib.mkEnableOption "LVM on LUKS on BTRFS Layout";

        osDisks = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "/dev/sda" ];
          description = "List of disks to partition";
        };

        swapSize = lib.mkOption {
          type = lib.types.str;
          default = "8G";
          description = "Size of the swap file";
        };
      };

      features = {
        boot = {
          plymouth.enable = lib.mkEnableOption "Plymouth Boot Animation";
          grub-luks-btrfs.enable = lib.mkEnableOption "GRUB with LUKS and BTRFS support";
        };

        desktop-environment = lib.mkOption {
          type = lib.types.enum [
            "gnome"
            "mango"
            "none"
          ];
          default = "none";
          description = "Which desktop environment to enable for this host.";
        };
      };

      primaryUser = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "Unknown User";
          description = "Name of primary user";
        };

        email = lib.mkOption {
          type = lib.types.str;
          default = "john.doe@gmail.com";
          description = "Email of primary user";
        };

        username = lib.mkOption {
          type = lib.types.str;
          default = "unknown";
          description = "Username of primary user";
        };

        nixosConfigPath = lib.mkOption {
          type = lib.types.path;
          default = /etc/nixos;
          description = "The absolute path to NixOS configuration";
        };

        dotfilesPath = lib.mkOption {
          type = lib.types.path;
          default = /etc/nixos/dotfiles;
          description = "The absolute path to the dotfiles";
        };
      };
    };
  };
}
