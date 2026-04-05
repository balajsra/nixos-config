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
            boot.grub-luks-btrfs.enable = true;
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
      ];

      networking.hostName = "${hostname}";
      time.timeZone = "${timezone}";

      # Run unpatched dynamic binaries on NixOS
      programs.nix-ld.enable = true;

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
      ];
    }
  );
}
