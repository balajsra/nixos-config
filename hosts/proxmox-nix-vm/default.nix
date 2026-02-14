{ vars, hostName, timeZone, ... }:

{
  imports =
    [
      ./hardware.nix
      ../../modules/nixos/disko/lvm-luks-btrfs.nix
      ../../modules/nixos/base.nix
      ../../modules/nixos/boot/grub-luks.nix
      ../../modules/nixos/desktop/gnome.nix
      ../../modules/nixos/services/openssh-server.nix
      ../../modules/nixos/services/pipewire.nix
    ];

  networking.hostName = "${hostName}"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "${timeZone}";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit vars; };
      users.${vars.username} = {
          imports = [
              ../../modules/home/base.nix
              ../../modules/home/shell.nix
          ];
      };
  };
}
