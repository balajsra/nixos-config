{
  self,
  inputs,
  withSystem,
  ...
}:
let
  hostname = "powerspec";
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
                "/dev/nvme0n1"
              ];
              swapSize = "4G";
            };
          };

          features = {
            boot = {
              grub-luks-btrfs.enable = true;
              plymouth.enable = true;
              kernel = "vanilla-latest";
            };

            display-manager = "dms-greeter";
            desktop-environment = "mango";

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
              gnucash.enable = true;
              obsidian.enable = true;
              qalculate.enable = true;
              thunderbird.enable = true;
              zathura.enable = true;
              libreoffice.enable = true;
            };

            networking = {
              ssh-server.enable = false;
              ssh-client.enable = true;
              vpn = {
                enable = true;
                home = false;
                proton = true;
              };
              location.enable = true;
            };

            file-sharing = {
              nextcloud.enable = true;
              syncthing.enable = true;
              localsend.enable = true;
              samba-client = {
                enable = true;
                fileserver.enable = true;
                mediaserver.enable = true;
              };
            };

            media = {
              scraper.enable = true;
              video.enable = true;
              audio.enable = true;
              image.enable = true;
              management.enable = true;
            };

            hardware = {
              bluetooth.enable = true;
              sound.enable = true;
              system76.enable = false;
              racing-wheel = {
                enable = true;
                logitech.enable = true;
              };
            };

            comms.enable = true;

            fonts = {
              enable = true;
              nerd.enable = true;
              emojis.enable = true;
              japanese.enable = true;
              korean.enable = true;
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
              self.homeModules.data-dirs
              self.homeModules.desktop-environment
              self.homeModules.development
              self.homeModules.editor
              self.homeModules.file-sharing
              self.homeModules.gaming
              self.homeModules.git
              self.homeModules.media
              self.homeModules.networking
              self.homeModules.office
              self.homeModules.phone
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
        self.nixosModules.data-dirs
        self.nixosModules.desktop-environment
        self.nixosModules.display-manager
        self.nixosModules.editor
        self.nixosModules.file-sharing
        self.nixosModules.fonts
        self.nixosModules.gaming
        self.nixosModules.git
        self.nixosModules.kernel
        self.nixosModules.location
        self.nixosModules.networking
        self.nixosModules.office
        self.nixosModules.partitions
        self.nixosModules.phone
        self.nixosModules.printing
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
    {
      modulesPath,
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "uas"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ "dm-snapshot" ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "${architecture}";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
