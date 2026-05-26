{ self, lib, ... }:

{
  flake.nixosModules.variables = {
    options = {
      storage = {
        lvm-luks-btrfs = {
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
      };

      features = {
        boot = {
          plymouth.enable = lib.mkEnableOption "Plymouth Boot Animation";
          grub-luks-btrfs.enable = lib.mkEnableOption "GRUB with LUKS and BTRFS support";
          kernel = lib.mkOption {
            type = lib.types.enum [
              "vanilla-stable"
              "vanilla-latest"
              "liqorix-latest"
              "xanmod-stable"
              "xanmod-latest"
              "zen-latest"
            ];
            default = "vanilla-stable";
            description = "Which kernel package to use";
          };
        };

        display-manager = lib.mkOption {
          type = lib.types.enum [
            "gdm"
            "greetd"
          ];
          default = "gdm";
          description = "Which display manager to enable for this host.";
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

        terminal = {
          bash.enable = lib.mkEnableOption "Enable bash shell";
          fish.enable = lib.mkEnableOption "Enable fish shell";
          foot.enable = lib.mkEnableOption "Enable Foot terminal";
          ghostty.enable = lib.mkEnableOption "Enable Ghostty terminal";
        };

        networking = {
          ssh-server.enable = lib.mkEnableOption "Enable SSH server";
          ssh-client.enable = lib.mkEnableOption "Enable SSH client";
          vpn = {
            enable = lib.mkEnableOption "Enable VPN support";
            home = lib.mkEnableOption "Enable home VPN configurations";
            proton = lib.mkEnableOption "Enable Proton VPN configurations";
          };
        };

        file-sharing = {
          nextcloud.enable = lib.mkEnableOption "NextCloud Client";
          syncthing.enable = lib.mkEnableOption "Syncthing file sync";
        };

        hardware = {
          system76.enable = lib.mkEnableOption "Enable System76 hardware support";
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
