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

      # ... keeping your existing boot.initrd and microcode settings identical ...

      # =========================================================================
      # BASE BOOT PROFILE: INTEGRATED GRAPHICS (Intel Only)
      # =========================================================================

      # 1. Provide a visible tag in the main GRUB line so you know it's Integrated
      system.nixos.tags = [ "integrated-graphics" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Only load the Intel driver by default
      services.xserver.videoDrivers = [ "modesetting" ];

      # Kernel blocks to forcefully isolate and spin down the NVIDIA card
      boot.blacklistedKernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];

      # Cut the PCIe link management to let the card sleep completely unhindered
      boot.kernelParams = [
        "rcutree.use_softirq=0"
        "nouveau.modeset=0"
      ];

      # =========================================================================
      # SPECIALISATION PROFILE: DISCRETE GPU (NVIDIA Sync Mode)
      # =========================================================================
      specialisation = {
        discrete-gpu.configuration = {
          # Override the menu tag string
          system.nixos.tags = [ "discrete-gpu" ];

          # Re-enable the NVIDIA drivers for this boot mode
          services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
          boot.blacklistedKernelModules = lib.mkForce [ ];
          boot.kernelParams = lib.mkForce [ ];

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

            # Force the dedicated card to own the display pipeline directly
            sync.enable = lib.mkForce true;
            offload.enable = lib.mkForce false;
            offload.enableOffloadCmd = lib.mkForce false;
          };
        };
      };
    };
}
