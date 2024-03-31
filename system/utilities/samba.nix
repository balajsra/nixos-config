{ config, lib, pkgs, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    cifs-utils
    lxqt.lxqt-policykit # provides a default authentification client for policykit
  ];

  fileSystems."/mnt/fileserver" = {
    device = "//192.168.12.5/fileserver";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

    in [
      "${automount_opts},
      credentials=/etc/nixos/smb-secrets,
      ${config.users.users.${userSettings.username}.uid},
      gid=${config.users.groups.${userSettings.username}.gid}"
    ];
    # Make sure to create `/etc/nixos/smb-secrets` with following content
    # where domain can be optional
    # username=<USERNAME>
    # domain=<DOMAIN>
    # password=<PASSWORD>
  };

  # Samba discovery of machines and shares
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';

  # GVFS
  services.gvfs.enable = true;
}
