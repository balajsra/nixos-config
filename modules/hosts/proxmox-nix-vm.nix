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
      self.nixosModules."${hostname}-configuration"
      self.nixosModules."${hostname}-hardware"
      self.nixosModules.variables
      self.nixosModules.home-manager
      (
        { config, lib, ... }:
        {
          nixpkgs.hostPlatform = lib.mkDefault "${architecture}";
          # Unfree Software: https://nixos.wiki/wiki/Unfree_Software
          nixpkgs.config.allowUnfree = true;

          # Modify pkgs to include a `stable` keyword to reference stable package repo
          # Unstable packages installed as `pkgs.<package-name>`
          # Stable packages installed as `pkgs.stable.<package-name>`
          nixpkgs.overlays = [
            (final: prev: {
              stable = import inputs.nixpkgs-stable {
                system = final.stdenv.hostPlatform.system;
                config = config.nixpkgs.config;
              };
            })
            inputs.dracula-signal-desktop.overlays
          ];

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
              samba-client = {
                enable = false;
                fileserver.enable = false;
                mediaserver.enable = false;
              };
            };

            hardware = {
              system76.enable = false;
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
              self.homeModules.networking
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
        self.nixosModules.boot-animation
        self.nixosModules.boot-loader
        self.nixosModules.desktop-environment
        self.nixosModules.display-manager
        self.nixosModules.editor
        self.nixosModules.file-sharing
        self.nixosModules.fonts
        self.nixosModules.git
        self.nixosModules.kernel
        self.nixosModules.location
        self.nixosModules.networking
        self.nixosModules.partitions
        self.nixosModules.removable-media
        self.nixosModules.security
        self.nixosModules.system76
        self.nixosModules.utils
      ];

      networking.hostName = "${hostname}";
      time.timeZone = "${timezone}";

      # Run unpatched dynamic binaries on NixOS
      programs.nix-ld.enable = true;

      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Storage Optimization: https://nixos.wiki/wiki/Storage_optimization
        # Optimising the store
        optimise = {
          automatic = true;
          dates = [ "01:00" ]; # Daily at 1:00 AM (or next boot)
        };

        # Garbage Collection
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
      };

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
