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
      inputs.home-manager.nixosModules.home-manager
      (
        { config, lib, ... }:
        {
          nixpkgs.pkgs = withSystem architecture ({ pkgs, ... }: pkgs);
          nixpkgs.hostPlatform = lib.mkDefault "${architecture}";

          storage = {
            enable = true;
            osDisks = [
              "/dev/nvme0n1"
              "/dev/sda"
            ];
            swapSize = "2G";
          };

          features = {
            boot = {
              grub-luks-btrfs.enable = true;
              plymouth.enable = true;
            };
          };

          primaryUser = {
            name = "Sravan Balaji";
            email = "sr98vn@gmail.com";
            username = "sravan";
          };
        }
      )
    ];
  };

  flake.nixosModules."${hostname}-configuration" =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.admin
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
        self.nixosModules.night-light
        self.nixosModules.partitions
        self.nixosModules.phone
        self.nixosModules.printing
        self.nixosModules.removable-media
        self.nixosModules.sound
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
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      boot.initrd.kernelModules = [ "dm-snapshot" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

  flake.homeConfigurations.admin = withSystem architecture (
    { pkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeModules.admin
        self.homeModules.comms
        self.homeModules.data-dirs
        self.homeModules.desktop-environment
        self.homeModules.editor
        self.homeModules.file-sharing
        self.homeModules.gaming
        self.homeModules.git
        self.homeModules.media
        self.homeModules.night-light
        self.homeModules.office
        self.homeModules.phone
        self.homeModules.terminal
        self.homeModules.web-browser
      ];
    }
  );
}
