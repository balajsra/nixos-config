{ self, inputs, ... }:
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
        { ... }:
        {
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
      networking.hostName = "${hostname}";

      time.timeZone = "${timezone}";

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

      nixpkgs.hostPlatform = lib.mkDefault "${architecture}";
    };
}
