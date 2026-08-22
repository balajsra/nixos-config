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

            display-manager = "dms-greeter";
            desktop-environment = "mango";

            display = {
              kanshi = {
                enable = false;
                profiles = [ ];
              };
            };

            terminal = {
              bash.enable = true;
              fish.enable = true;
              tmux.enable = true;
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
              sweethome3d.enable = true;
              drawy.enable = true;
            };

            networking = {
              ssh-server.enable = false;
              ssh-client.enable = true;
              vpn = {
                enable = true;
                home = true;
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

            gaming = {
              gamemode.enable = true;
              gamescope.enable = true;
              steam.enable = true;
              wine.enable = true;
              vkbasalt.enable = true;
              sunshine.enable = false;
              lutris.enable = true;
              mangohud.enable = true;
              chiaki.enable = true;
              prism-launcher.enable = true;
              vintage-story.enable = true;
              hytale-launcher.enable = true;
              heroic.enable = true;
            };

            hardware = {
              bluetooth.enable = true;
              sound.enable = true;
              printing.enable = true;
              scanning.enable = true;
              system76.enable = true;
              racing-wheel = {
                enable = false;
                logitech.enable = false;
              };
              power = {
                handle-power-keys.enable = true;
                ignore-lid-switch.enable = true;
                disable-wakeup-triggers.enable = true;
                thermald.enable = true;
                auto-cpufreq.enable = true;
              };
              graphics = {
                amd-gpu.enable = false;
                nvidia-gpu.enable = true;
              };
              firmware.enable = true;
            };

            comms = {
              beeper.enable = true;
              signal.enable = true;
              zoom.enable = true;
            };

            phone = {
              kdeconnect.enable = true;
              android-tools.enable = true;
            };

            security = {
              sops.enable = true;
              secret-service.enable = true;
              bitwarden.enable = true;
            };

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
        self.nixosModules.firmware
        self.nixosModules.fonts
        self.nixosModules.gaming
        self.nixosModules.git
        self.nixosModules.graphics
        self.nixosModules.kernel
        self.nixosModules.location
        self.nixosModules.networking
        self.nixosModules.office
        self.nixosModules.partitions
        self.nixosModules.phone
        self.nixosModules.power
        self.nixosModules.printer
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

      # =========================================================================
      # BASE PROFILE: INTEGRATED GRAPHICS (The default)
      # =========================================================================
      system.nixos.tags = [ "integrated-graphics" ];

      # Disable NVIDIA GPU
      features.hardware.graphics.nvidia-gpu.enable = lib.mkDefault false;

      # Force the system to ignore NVIDIA entirely in the base profile
      services.xserver.videoDrivers = [ "modesetting" ];

      boot.blacklistedKernelModules = [
        "nvidia"
        "nouveau"
        "nvidiafb" # Added to prevent framebuffer from keeping the card awake
      ];

      # UDEV RULE: Force Runtime Power Management
      # This tells the kernel to aggressively cut power to the PCI device
      # when the system is idle, regardless of whether a driver is loaded.
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ATTR{power/control}="auto", ATTR{power/runtime_enabled}="enabled"
      '';

      # =========================================================================
      # SPECIALISATION PROFILE: DISCRETE GPU
      # =========================================================================
      specialisation = {
        discrete-gpu.configuration = {
          system.nixos.tags = [ "discrete-gpu" ];

          # Enable NVIDIA GPU
          features.hardware.graphics.nvidia-gpu.enable = lib.mkForce true;

          # Un-blacklist the proprietary driver
          boot.blacklistedKernelModules = lib.mkForce [ ];

          # Host specific GPU settings
          hardware.nvidia = {
            powerManagement = {
              enable = true;
              finegrained = true;
            };
            prime = {
              intelBusId = "PCI:0:2:0";
              nvidiaBusId = "PCI:1:0:0";
              offload.enable = true;
            };
          };
        };
      };
    };
}
