{ self, inputs, ... }:

{
  flake.nixosConfigurations."proxmox-nix-vm" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules."host-proxmox-nix-vm"
      self.nixosModules."hardware-proxmox-nix-vm"
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
}
