{
  inputs,
  vars,
  hostName,
  timeZone,
  ...
}:

{
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/boot/grub-luks.nix
    ../../modules/nixos/boot/kernel.nix
    ../../modules/nixos/boot/plymouth.nix
    ../../modules/nixos/cli/utils.nix
    ../../modules/nixos/desktop/fonts.nix
    ../../modules/nixos/desktop/ly.nix
    ../../modules/nixos/desktop/mangowm.nix
    ../../modules/nixos/dev/vim.nix
    ../../modules/nixos/disko/lvm-luks-btrfs.nix
    ../../modules/nixos/filesystem/data.nix
    ../../modules/nixos/filesystem/udiskie.nix
    ../../modules/nixos/networking/firewall.nix
    ../../modules/nixos/networking/network-manager.nix
    ../../modules/nixos/networking/openssh-server.nix
    ../../modules/nixos/networking/wireguard.nix
    ../../modules/nixos/services/storage-optimization.nix
    ./hardware.nix
  ];

  networking.hostName = "${hostName}"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "${timeZone}";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs vars; };
    users.${vars.username} = {
      imports = [
        ../../modules/home/base.nix
        ../../modules/home/cli/bash.nix
        ../../modules/home/cli/fish.nix
        ../../modules/home/cli/foot.nix
        ../../modules/home/cli/tmux.nix
        ../../modules/home/data/nextcloud.nix
        ../../modules/home/data/syncthing.nix
        ../../modules/home/data/user-data.nix
        ../../modules/home/desktop/mangowm.nix
        ../../modules/home/dev/nix-development.nix
        ../../modules/home/media/ani-cli.nix
        ../../modules/home/media/celluloid.nix
        ../../modules/home/media/feishin.nix
        ../../modules/home/media/fladder.nix
        ../../modules/home/media/gimp.nix
        ../../modules/home/media/picard.nix
        ../../modules/home/media/yt-dlp.nix
        ../../modules/home/office/gnucash.nix
        ../../modules/home/office/obsidian.nix
        ../../modules/home/office/qalculate.nix
        ../../modules/home/office/thunderbird.nix
        ../../modules/home/office/zathura.nix
        ../../modules/home/web/zen-browser.nix
      ];
    };
  };
}
