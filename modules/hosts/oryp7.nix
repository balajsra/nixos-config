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
              "/dev/nvme0n1"
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
        self.nixosModules.kernel
        self.nixosModules.git
      ];

      networking.hostName = "${hostname}";
      time.timeZone = "${timezone}";

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Run unpatched dynamic binaries on NixOS
      programs.nix-ld.enable = true;

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

  flake.homeConfigurations."${user}" = withSystem architecture (
    { pkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeModules."${user}"
        self.homeModules.git
      ];
    }
  );
}
