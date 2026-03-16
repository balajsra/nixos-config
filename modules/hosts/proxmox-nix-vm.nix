{ ... }:
let
  hostname = "proxmox-nix-vm";
  timezone = "America/New_York";
  architecture = "x86_64-linux";
in
{
  flake.nixosModules."host-${hostname}" =
    { pkgs, ... }:
    {
      networking.hostName = "${hostname}";

      time.timeZone = "${timezone}";

      # Do not change, this is a safety anchor to prevent
      # system from breaking or losing data during an upgrade
      system.stateVersion = "25.11";
    };

  flake.nixosModules."hardware-${hostname}" =
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
