{ config, lib, pkgs, vars, hostName, architecture, timeZone, osDisks, swapSize, ... }:

{
  imports =
    [
      ./hardware.nix
      ../../modules/nixos/disko/lvm-luks-btrfs.nix
    ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev"; # "nodev" is required for UEFI/EFI installs
      efiSupport = true;
      enableCryptodisk = true; # Allows GRUB to "see" encrypted partitions
    };
  };

  boot.initrd = {
    supportedFilesystems = [ "btrfs" ];
    availableKernelModules = [ "aesni_intel" "cryptd" "dm_mod" "dm_crypt" ];
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "${hostName}"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "${timeZone}";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.ly.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${vars.username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Do not change, this is a safety anchor to prevent
  # system from breaking or losing data during an upgrade
  system.stateVersion = "25.11";

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
