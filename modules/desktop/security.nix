{
  self,
  inputs,
  config,
  osConfig,
  ...
}:
{
  flake.nixosModules.security = {
    imports = [
      self.nixosModules.sops
      self.nixosModules.secret-service
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.homeModules.security = {
    imports = [
      self.homeModules.bitwarden
      self.homeModules.sops
      inputs.sops-nix.homeManagerModules.sops
    ];
  };

  flake.nixosModules.sops =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      user = config.primaryUser.username;
    in
    {
      config = lib.mkIf (config.features.security.sops.enable) {
        environment.systemPackages = with pkgs; [
          age
          sops
          mkpasswd
        ];

        sops = {
          defaultSopsFile = "/home/${user}/.config/nixos/secrets.yaml";
          validateSopsFiles = false;
          age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
        };
      };
    };

  flake.homeModules.bitwarden =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.security.bitwarden.enable) {
        home.packages = with pkgs; [
          bitwarden-desktop
          bitwarden-cli
          bitwarden-menu
        ];
      };
    };

  flake.homeModules.sops =
    {
      osConfig,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.security.sops.enable) {
        sops = {
          age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          defaultSopsFile = "/home/${osConfig.primaryUser.username}/.config/nixos/secrets.yaml";
          validateSopsFiles = false;
        };
      };
    };

  flake.nixosModules.secret-service =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.security.secret-service.enable) {
        # https://wiki.nixos.org/wiki/Secret_Service
        services.gnome.gnome-keyring.enable = true;
        environment.systemPackages = with pkgs; [
          seahorse
        ];
      };
    };
}
