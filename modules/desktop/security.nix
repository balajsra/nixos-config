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
      secretsPath = builtins.toString inputs.nix-secrets;
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
          defaultSopsFile = "${secretsPath}/secrets.yaml";
          validateSopsFiles = false;
          age = {
            # automatically import host SSH keys as age keys
            sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            # this will use an age key that is expected to already be in the filesystem
            keyFile = "/var/lib/sops-nix/key.txt";
            # generate a new key if the key specified above does not exist
            generateKey = true;
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
    let
      secretsPath = builtins.toString inputs.nix-secrets;
    in
    {
      config = lib.mkIf (osConfig.features.security.sops.enable) {
        sops = {
          # This is the dev access key and needs to have been copied to this location on the host
          age.keyFile = "/home/${osConfig.primaryUser.username}/.config/sops/age/keys.txt";

          defaultSopsFile = "${secretsPath}/secrets.yaml";
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
