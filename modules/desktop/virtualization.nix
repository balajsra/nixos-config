{ self, config, ... }:

{
  flake.nixosModules.virtualization = {
    imports = [
      self.nixosModules.qemu
      self.nixosModules.libvirt
      self.nixosModules.virt-manager
    ];
  };

  flake.nixosModules.qemu =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.virtualization.qemu.enable) {
        # https://wiki.nixos.org/wiki/QEMU
        environment.systemPackages = with pkgs; [
          qemu
          quickemu
        ];
      };
    };

  flake.nixosModules.libvirt =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.virtualization.libvirt.enable) {
        # https://wiki.nixos.org/wiki/Libvirt
        virtualisation = {
          libvirtd = {
            enable = true;

            # Enable TPM emulation
            qemu.swtpm.enable = true;
          };

          # Enable USB redirection
          spiceUSBRedirection.enable = true;
        };

        users.users."${config.primaryUser.username}".extraGroups = [ "libvirtd" ];
      };
    };

  flake.nixosModules.virt-manager =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.virtualization.virt-manager.enable) {
        # https://wiki.nixos.org/wiki/Virt-manager
        programs.virt-manager.enable = true;
      };
    };
}
