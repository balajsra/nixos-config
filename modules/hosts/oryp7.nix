{
  self,
  inputs,
  withSystem,
  ...
}:
let
  hostname = "oryp7";
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
          ];

          storage = {
            lvm-luks-btrfs = {
              enable = true;
              osDisks = [
                "/dev/nvme0n1"
                "/dev/sda"
              ];
              swapSize = "2G";
            };
          };

          features = {
            boot = {
              grub-luks-btrfs.enable = true;
              plymouth.enable = true;
              kernel = "vanilla-latest";
            };

            display-manager = "greetd";
            desktop-environment = "mango";

            terminal = {
              bash.enable = true;
              fish.enable = true;
              emulator = "ghostty";
            };

            networking = {
              ssh-server.enable = false;
              ssh-client.enable = true;
              vpn = {
                enable = true;
                home = true;
                proton = true;
              };
            };

            file-sharing = {
              nextcloud.enable = true;
              syncthing.enable = true;
            };

            hardware = {
              system76.enable = true;
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
              self.homeModules.night-light
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
        self.nixosModules.data-dirs
        self.nixosModules.desktop-environment
        self.nixosModules.display-manager
        self.nixosModules.editor
        self.nixosModules.fonts
        self.nixosModules.gaming
        self.nixosModules.git
        self.nixosModules.kernel
        self.nixosModules.location
        self.nixosModules.networking
        self.nixosModules.night-light
        self.nixosModules.partitions
        self.nixosModules.phone
        self.nixosModules.printing
        self.nixosModules.removable-media
        self.nixosModules.security
        self.nixosModules.sound
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
    {
      modulesPath,
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.loader.grub = {
        # 1. Hide the standard auto-generated top-level entries to eliminate duplicates
        configurationLimit = 0;

        # 2. Hardcode the main menu selections with accurate dynamic path pointers
        extraEntries = ''
          menuentry "NixOS - Integrated Graphics (Intel Only)" --class nixos {
            # Points directly to the primary, default boot choice file
            configfile /grub/kernels.cfg
          }
          menuentry "NixOS - Dedicated Graphics (NVIDIA Sync)" --class nixos {
            # Specialisations are compiled natively as a sub-profile under the current system closure
            configfile /grub/specialisations/discrete-gpu.cfg
          }
        '';
      };

      # ... keeping your existing boot.initrd and microcode settings identical ...

      # =========================================================================
      # BASE BOOT PROFILE: INTEGRATED GRAPHICS (Intel Only)
      # =========================================================================

      system.nixos.tags = [ "integrated-graphics" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.xserver.videoDrivers = [ "modesetting" ];

      # 1. Blacklist drivers so they don't claim the hardware
      boot.blacklistedKernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
        "nouveau"
      ];

      # 2. Kernel parameters to enable aggressive PCIe runtime power management
      boot.kernelParams = [
        "pcie_port_pm=off"
        "nvidia-drm.modeset=1"
      ];

      # 3. Force the kernel to write "auto" to the NVIDIA card's power control
      # This forces the PCIe bus to transition the unmanaged card from D0 to D3cold
      services.udev.extraRules = ''
        # Remove NVIDIA USB Type-C/Audio controllers if present on the card to allow sleep
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0303", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

        # Cut power to the main 3D VGA controller (RTX 3070)
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x249d", ATTR{power/control}="auto"
      '';

      # =========================================================================
      # SPECIALISATION PROFILE: DISCRETE GPU (NVIDIA Sync Mode)
      # =========================================================================
      specialisation = {
        discrete-gpu.configuration = {
          system.nixos.tags = [ "discrete-gpu" ];

          # Re-enable everything cleanly
          services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
          boot.blacklistedKernelModules = lib.mkForce [ ];
          boot.kernelParams = lib.mkForce [ ];

          # Wipe out the power-down udev rules for this generation block
          services.udev.extraRules = lib.mkForce "";

          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = true;
            open = true;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.stable;
          };

          hardware.nvidia.prime = {
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
            sync.enable = lib.mkForce true;
            offload.enable = lib.mkForce false;
            offload.enableOffloadCmd = lib.mkForce false;
          };
        };
      };
    };
}
