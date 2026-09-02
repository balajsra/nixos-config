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
      keyDir = "/var/lib/sops-nix";
      keyFile = "${keyDir}/user-key.txt";
    in
    {
      config = lib.mkIf (config.features.security.sops.enable) {
        environment.systemPackages = with pkgs; [
          age
          sops
          ssh-to-age
          mkpasswd
        ];

        # Ensure directory is traversable (755) and derive the user age key from SSH host key
        system.activationScripts.sopsUserKey = {
          supportsDryActivation = true;
          text = ''
            mkdir -p ${keyDir}
            chmod 755 ${keyDir}
            if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
              ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > ${keyFile}
              chown ${user}:users ${keyFile}
              chmod 600 ${keyFile}
            fi
          '';
        };

        sops = {
          defaultSopsFile = "/home/${user}/.config/nixos/secrets.yaml";
          validateSopsFiles = false;
          age = {
            # Use host SSH key directly for NixOS system secrets (e.g. hashedPasswordFile)
            sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
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
          # Home Manager uses the user-owned age key derived from the host key
          age.keyFile = "/var/lib/sops-nix/user-key.txt";

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
