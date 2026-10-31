{
  description = "Flake of Sravan's NixOS";

  inputs = {
    ##############
    # Nix Config #
    ##############
    # Nix Packages
    # Unstable by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Any version of any nixpkgs package, from one flake input
    multiverse.url = "github:fzakaria/nixpkgs-multiverse";

    # Dendritic Pattern Support
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning and formatting
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ###########
    # Secrets #
    ###########
    # Secrets Management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ################
    # Applications #
    ################
    # Automatic CPU Speed & Power Optimizer
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # File Manager for Dux Shell
    dux-files = {
      url = "github:duxlabs-dev/dux-files";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Display Manager for Dux Shell
    dux-greeter = {
      url = "github:duxlabs-dev/dux-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop Shell for Wayland Compositors
    dux-shell = {
      url = "github:duxlabs-dev/dux-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Search interface for Dux Shell
    dux-search = {
      url = "github:duxlabs-dev/dux-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hytale Launcher
    hytale-launcher = {
      url = "github:JPyke3/hytale-launcher-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mango Wayland Compositor
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen Browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ##################
    # Dracula Themes #
    ##################
    # Dracula Beeper Theme
    dracula-beeper-theme = {
      url = "github:dracula/beeper";
      flake = false;
    };

    # Dracula Dux Shell Theme
    dracula-dux-shell-theme = {
      url = "github:dracula/dankmaterialshell";
      flake = false;
    };

    # Dracula Fish Theme
    dracula-fish-theme = {
      url = "github:dracula/fish";
      flake = false;
    };

    # Dracula GIMP Theme
    dracula-gimp-theme = {
      url = "github:dracula/gimp";
      flake = false;
    };

    # Dracula GTK Theme
    dracula-gtk-theme = {
      url = "github:dracula/gtk";
      flake = false;
    };

    # Dracula Signal Desktop App Theme
    dracula-signal-desktop-theme = {
      url = "github:dracula/signal-desktop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dracula TTY Theme
    dracula-tty-theme = {
      url = "github:dracula/tty";
      flake = false;
    };

    # Dracula Yazi Theme
    dracula-yazi-theme = {
      url = "github:dracula/yazi";
      flake = false;
    };

    # Dracula Zathura Theme
    dracula-zathura-theme = {
      url = "github:dracula/zathura";
      flake = false;
    };

    ######################
    # Dracula Pro Themes #
    ######################
    # (Private) Dracula Pro Ghostty Theme
    dracula-pro-ghostty-theme = {
      url = "github:dracula-pro/ghostty";
      flake = false;
    };

    # (Private) Dracula Pro Starship Theme
    dracula-pro-starship-theme = {
      url = "github:dracula-pro/starship";
      flake = false;
    };

    # (Private) Dracula Pro Vim Theme
    dracula-pro-vim-theme = {
      url = "github:dracula-pro/vim";
      flake = false;
    };

    # (Private) Dracula Pro VS Code Theme
    dracula-pro-vscode-theme = {
      url = "github:dracula-pro/visual-studio-code";
      flake = false;
    };

    ################
    # Other Themes #
    ################
    # Eza Themes
    eza-themes = {
      url = "github:eza-community/eza-themes";
      flake = false;
    };

    # Fallout GRUB Theme
    fallout-grub-theme = {
      url = "github:shvchk/fallout-grub-theme";
      flake = false;
    };

    # Fallout Plymouth Theme
    fallout-plymouth-theme = {
      url = "github:balajsra/fallout-plymouth-theme";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
