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
    {
      config,
      lib,
      pkgs,
      ...
    }:
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

        # Allow libvirt bridge traffic through the host firewall
        networking.firewall.trustedInterfaces = [ "virbr0" ];

        # Automatically start the 'default' libvirt network on boot
        systemd.services.libvirt-default-network = {
          description = "Start libvirt default network";
          requires = [ "libvirtd.service" ];
          after = [ "libvirtd.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "libvirt-default-network-start" ''
              # Check if the network is active
              if ! ${pkgs.libvirt}/bin/virsh net-info default 2>/dev/null | grep -q "Active:.*yes"; then
                # If defined but inactive, start it
                ${pkgs.libvirt}/bin/virsh net-start default || true
              fi
            '';
            ExecStop = pkgs.writeShellScript "libvirt-default-network-stop" ''
              if ${pkgs.libvirt}/bin/virsh net-info default 2>/dev/null | grep -q "Active:.*yes"; then
                ${pkgs.libvirt}/bin/virsh net-destroy default || true
              fi
            '';
          };
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
