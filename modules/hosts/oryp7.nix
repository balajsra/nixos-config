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

      # =========================================================================
      # NATIVE GRUB TEXT OVERRIDE
      # =========================================================================
      boot.loader.grub = {
        enable = true;
        configurationLimit = 10;
        extraPerEntryConfig = ''
          case "$title" in
            *"Default"*|*"Generation"*)
              title="NixOS - Integrated Graphics (Intel Only)"
              ;;
          esac
        '';
      };

      # =========================================================================
      # BASE PROFILE: INTEGRATED GRAPHICS (Absolute Driver & Hardware Block)
      # =========================================================================
      system.nixos.tags = [ "integrated-graphics" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Force the display system to ONLY see modesetting (Intel)
      services.xserver.videoDrivers = [ "modesetting" ];

      # 1. Hard block all variants of the NVIDIA and Nouveau drivers from loading
      boot.blacklistedKernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
        "nouveau"
      ];

      # 2. Shut down PCIe link management & disable the driver modeset globally
      boot.kernelParams = [
        "pcie_port_pm=off"
        "nvidia-drm.modeset=0"
      ];

      # 3. Use udev to completely unbind and remove the entire device from the
      # kernel's PCI bus infrastructure the split second it's detected on boot.
      # This tricks mangowm into believing the RTX 3070 doesn't physically exist,
      # preventing the probe and allowing the laptop firmware to drop it to D3cold.
      services.udev.extraRules = ''
        # Remove NVIDIA Audio and USB controllers if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0303", ATTR{remove}="1"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

        # Force clear the main 3D VGA controller (RTX 3070) from the active bus list
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x249d", ATTR{remove}="1"
      '';

      # =========================================================================
      # SPECIALISATION PROFILE: DISCRETE GPU (NVIDIA Sync Workstation Mode)
      # =========================================================================
      specialisation = {
        discrete-gpu.configuration = {
          system.nixos.tags = [ "discrete-gpu" ];

          # Restore the video drivers and wipe out the isolation parameters
          services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
          boot.blacklistedKernelModules = lib.mkForce [ ];
          boot.kernelParams = lib.mkForce [ ];
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
