{

  description = "Flake of Sravan's NixOS";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, disko, nix-doom-emacs, ... }:
    let
      # --- SYSTEM SETTINGS --- #
      systemSettings = {
        system = "x86_64-linux";               # System Architecture
        hostname = "oryp7";                    # Hostname
        profile = "personal";                  # Select a profile defined from profiles directory
        timezone = "America/New_York";         # Time Zone
        locale = "en_US.UTF-8";                # Locale
        diskoConfig = "luks-btrfs-subvolumes"; # Select the disko config that was used to partition drive
        hwConfig = "oryp7";                    # Select the hardware config from hardware directory
        desktop = "dwm";                       # Selected window manager or desktop environment
        desktopType = "x11";                   # x11 or wayland
      };

      # --- USER SETTINGS --- #
      userSettings = rec {
        username = "sravan";          # Username
        name = "Sravan Balaji";       # Name/Identifier
        email = "balajsra@umich.edu"; # Email (used for certain configurations)
        dotfilesDir = "~/.dotfiles";  # Absolute path of the local repo
        theme = "dracula";            # Selected theme from themes directory
        browser = "vivaldi";          # Default browser
        term = "kitty";               # Default terminal command
        editor = "vim";               # Default editor
        spawnEditor =
          if (editor == "emacsclient") then
            "emacsclient -c -a 'emacs'"
          else
            (if (editor == "vim") then
               "exec " + term + " -e " + editor
             else
               editor
            );
      };

      pkgs = import nixpkgs {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

      pkgs-stable = import nixpkgs-stable {
        system = systemSettings.system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };

      lib = nixpkgs.lib;

    in {
      homeConfigurations = {
        user = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix")
            nix-doom-emacs.hmModule
          ];
          extraSpecialArgs = {
            inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
          };
        };
      };

      nixosConfigurations = {
        system = lib.nixosSystem {
          system = systemSettings.system;
          modules = [
            (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")
            disko.nixosModules.disko
            (./. + "/disko" + ("/" + systemSettings.diskoConfig) + ".nix")
          ];
          specialArgs = {
            inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
          };
        };
      };
    };
}
