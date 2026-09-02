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
          ssh-to-age
          mkpasswd
        ];

        sops = {
          defaultSopsFile = "/home/${user}/.config/nixos/secrets.yaml";
          validateSopsFiles = false;

          age = {
            # sops-nix natively converts SSH keys to age keys in early setup
            sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            # Set keyFile to host key or fallback path if needed
            keyFile = "/var/lib/sops/age/keys.txt";
          };
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
    { osConfig, lib, ... }:
    {
      config = lib.mkIf (osConfig.features.security.sops.enable) {
        sops = {
          # Point Home Manager to the host SSH key directly or user SSH key
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

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
