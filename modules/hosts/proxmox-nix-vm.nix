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
      self.nixosModules.disko-lvm-luks-btrfs
      self.nixosModules.boot-grub-luks-btrfs
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

  flake.homeConfigurations."sravan@${hostname}" = withSystem architecture (
    { pkgs, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeModules.sravan
      ];
    }
  );

  flake.nixosModules."${hostname}-configuration" =
    { pkgs, ... }:
    {
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
}
