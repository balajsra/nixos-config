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
    dracula-beeper = {
      url = "github:dracula/beeper";
      flake = false;
    };

    # Dracula Dux Shell Theme
    dracula-dux-shell = {
      url = "github:dracula/dankmaterialshell";
      flake = false;
    };

    # Dracula Fish Theme
    dracula-fish = {
      url = "github:dracula/fish";
      flake = false;
    };

    # Dracula GIMP Theme
    dracula-gimp = {
      url = "github:dracula/gimp";
      flake = false;
    };

    # Dracula Signal Desktop App Theme
    dracula-signal-desktop = {
      url = "github:dracula/signal-desktop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dracula TTY Theme
    dracula-tty = {
      url = "github:dracula/tty";
      flake = false;
    };

    # Dracula Zathura Theme
    dracula-zathura = {
      url = "github:dracula/zathura";
      flake = false;
    };

    ######################
    # Dracula Pro Themes #
    ######################
    # (Private) Dracula Pro Ghostty Theme
    dracula-pro-ghostty = {
      url = "github:dracula-pro/ghostty";
      flake = false;
    };

    # (Private) Dracula Pro Starship Theme
    dracula-pro-starship = {
      url = "github:dracula-pro/starship";
      flake = false;
    };

    # (Private) Dracula Pro Vim Theme
    dracula-pro-vim = {
      url = "github:dracula-pro/vim";
      flake = false;
    };

    # (Private) Dracula Pro VS Code Theme
    dracula-pro-vscode = {
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
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
