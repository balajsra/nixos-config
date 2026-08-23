{ self, config, ... }:

{
  flake.nixosModules.virtualization = {
    imports = [
      self.nixosModules.virt-manager
    ];
  };

  flake.nixosModules.virt-manager =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.virtualization.virt-manager.enable) {
        # https://wiki.nixos.org/wiki/Virt-manager
        virtualisation.libvirtd.enable = true;
        programs.virt-manager.enable = true;
        users.users."${config.primaryUser.username}".extraGroups = [ "libvirtd" ];
      };
    };
}
