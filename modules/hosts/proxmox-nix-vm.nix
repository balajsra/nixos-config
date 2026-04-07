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
  user = "sravan";
in
{
  flake.nixosConfigurations."${hostname}" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules."${hostname}-configuration"
      self.nixosModules."${hostname}-hardware"
      self.nixosModules.partitions
      self.nixosModules.boot-loader
      self.nixosModules.boot-animation
      inputs.home-manager.nixosModules.home-manager
      (
        { config, lib, ... }:
        {
          nixpkgs.pkgs = withSystem architecture ({ pkgs, ... }: pkgs);
          nixpkgs.hostPlatform = lib.mkDefault "${architecture}";

          storageOptions = {
            enable = true;
            osDisks = [
              "/dev/sda"
            ];
            swapSize = "2G";
          };

          featureOptions = {
            boot = {
              grub-luks-btrfs.enable = true;
              plymouth.enable = true;
            };
          };
        }
      )
    ];
  };

  flake.nixosModules."${hostname}-configuration" =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules."${user}"
        self.nixosModules.display-manager
        self.nixosModules.editor
        self.nixosModules.git
        self.nixosModules.kernel
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

  flake.homeConfigurations."${user}" = withSystem architecture (
    { pkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      imports = [
        self.homeModules."${user}"
        self.homeModules.editor
        self.homeModules.git
        self.homeModules.terminal
      ];
    }
  );
}
