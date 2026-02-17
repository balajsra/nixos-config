{
  vars,
  hostName,
  timeZone,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/boot/grub-luks.nix
    ../../modules/nixos/desktop/gnome.nix
    ../../modules/nixos/disko/lvm-luks-btrfs.nix
    ../../modules/nixos/networking/firewall.nix
    ../../modules/nixos/networking/network-manager.nix
    ../../modules/nixos/networking/openssh-server.nix
    ../../modules/nixos/services/storage-optimization.nix
  ];

  networking.hostName = "${hostName}"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "${timeZone}";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit vars; };
    users.${vars.username} = {
      imports = [
        ../../modules/home/base.nix
        ../../modules/home/cli/shell.nix
        ../../modules/home/dev/nix-development.nix
      ];
    };
  };
}
