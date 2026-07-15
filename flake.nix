{
  description = "Flake of Sravan's NixOS";

  inputs = {
    # Nix Packages
    # Unstable by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Stable available if needed
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

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

    # Secrets Management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private secrets repo
    # Authenticate via SSH and use shallow clone
    nix-secrets = {
      url = "git+ssh://git@forgejo.sravanbalaji.com:2222/sravan/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    # Dracula Theme for Signal Desktop App
    dracula-signal-desktop = {
      url = "github:dracula/signal-desktop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop Shell for Window Managers
    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Search interface for DankMaterialShell
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Automatic CPU Speed & Power Optimizer
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Include submodules when building this flake
    self.submodules = true;
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
