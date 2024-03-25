{

  description = "Flake of Sravan's NixOS";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, stylix, disko, ... }:
    let
      # --- SYSTEM SETTINGS --- #
      systemSettings = {
        system = "x86_64-linux";               # System Architecture
        hostname = "oryp7";                    # Hostname
        profile = "personal";                  # Select a profile defined from profiles directory
        timezone = "America/New_York";         # Time Zone
        locale = "en_US.UTF-8";                # Locale
        diskoConfig = "luks-btrfs-subvolumes"; # Select the disko config that was used to partition drive
        desktopEnvironment = "gnome";          # Window Manager / Desktop Environment to use
      };

      # --- USER SETTINGS --- #
      userSettings = rec {
        username = "sravan";          # Username
        name = "Sravan Balaji";       # Name/Identifier
        email = "balajsra@umich.edu"; # Email (used for certain configurations)
        dotfilesDir = "~/.dotfiles";  # Absolute path of the local repo
        theme = "dracula";            # Selected theme from themes directory
        wm = "dwm";                   # Selected window manager or desktop environment
        wmType = "x11";               # x11 or wayland
        browser = "vivaldi";          # Default browser
        term = "kitty";               # Default terminal command
        editor = "emacsclient";       # Default editor
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
            (./. + "/profiles" + ("/" systemSettings.profile) + "/home.nix")
          ];
          extraSpecialArgs = {
            inherit pkgs-stable;
            inherit systemSettings;
            inherit userSettings;
            inherit (inputs) stylix;
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
            inherit (inputs) stylix;
          };
        };
      };
    };
}
