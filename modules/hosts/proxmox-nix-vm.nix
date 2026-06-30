{
  self,
  inputs,
  withSystem,
  ...
}:
let
  hostname = "proxmox-nix-vm";
  timezone = "America/New_York";
  architecture = "x86_64-linux";
in
{
  flake.nixosConfigurations."${hostname}" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { _module.args.inputs = inputs; }

      self.nixosModules."${hostname}-configuration"
      self.nixosModules."${hostname}-hardware"
      self.nixosModules.variables
      self.nixosModules.home-manager
      (
        { config, lib, ... }:
        {
          nixpkgs.hostPlatform = lib.mkDefault "${architecture}";

          storage = {
            lvm-luks-btrfs = {
              enable = true;
              osDisks = [
                "/dev/sda"
              ];
              swapSize = "2G";
            };
          };

          features = {
            boot = {
              grub-luks-btrfs.enable = true;
              plymouth.enable = true;
              kernel = "vanilla-stable";
            };

            display-manager = "gdm";
            desktop-environment = "gnome";

            terminal = {
              bash.enable = true;
              fish.enable = true;
              emulator = "ghostty";
            };

            editor = {
              vscode.enable = true;
              zed.enable = false;
              vim.enable = true;
              nano.enable = false;
              gui = "code";
              terminal = "vim";
            };

            browser = {
              zen.enable = true;
              default = "zen";
            };

            office = {
              gnucash.enable = false;
              obsidian.enable = false;
              qalculate.enable = false;
              thunderbird.enable = false;
              zathura.enable = false;
              libreoffice.enable = false;
            };

            networking = {
              ssh-server.enable = true;
              ssh-client.enable = true;
              vpn = {
                enable = false;
                home = false;
                proton = false;
              };
              location.enable = false;
            };

            file-sharing = {
              nextcloud.enable = false;
              syncthing.enable = false;
              localsend.enable = false;
              samba-client = {
                enable = false;
                fileserver.enable = false;
                mediaserver.enable = false;
              };
            };

            media = {
              scraper.enable = false;
              video.enable = false;
              audio.enable = false;
              image.enable = false;
              management.enable = false;
            };

            hardware = {
              bluetooth.enable = false;
              sound.enable = false;
              system76.enable = false;
              racing-wheel = {
                enable = false;
                logitech.enable = false;
              };
            };

            comms.enable = true;

            fonts = {
              enable = true;
              nerd.enable = false;
              emojis.enable = false;
              japanese.enable = false;
              korean.enable = false;
            };
          };

          primaryUser = {
            name = "Sravan Balaji";
            email = "sr98vn@gmail.com";
            username = "sravan";
            nixosConfigPath = /home/${config.primaryUser.username}/.config/nixos;
            dotfilesPath = /home/${config.primaryUser.username}/.config/nixos/dotfiles;
          };

          imports = [ self.nixosModules.admin ];
          home-manager.users."${config.primaryUser.username}" = {
            imports = [
              self.homeModules.admin
              self.homeModules.comms
              self.homeModules.desktop-environment
              self.homeModules.development
              self.homeModules.editor
              self.homeModules.git
              self.homeModules.media
              self.homeModules.networking
              self.homeModules.office
              self.homeModules.security
              self.homeModules.terminal
              self.homeModules.web-browser
            ];
          };
        }
      )
    ];
  };

  flake.nixosModules."${hostname}-configuration" =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.bluetooth
        self.nixosModules.boot-animation
        self.nixosModules.boot-loader
        self.nixosModules.core
        self.nixosModules.desktop-environment
        self.nixosModules.display-manager
        self.nixosModules.editor
        self.nixosModules.file-sharing
        self.nixosModules.fonts
        self.nixosModules.git
        self.nixosModules.kernel
        self.nixosModules.location
        self.nixosModules.networking
        self.nixosModules.office
        self.nixosModules.partitions
        self.nixosModules.racing-wheel
        self.nixosModules.removable-media
        self.nixosModules.security
        self.nixosModules.sound
        self.nixosModules.system76
        self.nixosModules.utils
      ];

      networking.hostName = "${hostname}";
      time.timeZone = "${timezone}";

      # Do not change, this is a safety anchor to prevent
      # system from breaking or losing data during an upgrade
      system.stateVersion = "25.11";
    };

  flake.nixosModules."${hostname}-hardware" =
    { modulesPath, lib, ... }:
    {
      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
      ];

      boot.initrd.availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
      ];
      boot.initrd.kernelModules = [ "dm-snapshot" ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];
    };
}
