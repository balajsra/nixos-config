{ self, inputs, ... }:

{
  flake.nixosConfigurations."proxmox-nix-vm" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules."host-proxmox-nix-vm"
      self.nixosModules."hardware-proxmox-nix-vm"
      self.nixosModules.disko-lvm-luks-btrfs
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
        }
      )
    ];
  };
}
