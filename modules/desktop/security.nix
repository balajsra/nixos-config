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
    { pkgs, config, ... }:
    let
      secretsPath = builtins.toString inputs.nix-secrets;
    in
    {
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

  flake.homeModules.bitwarden =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bitwarden-desktop
        bitwarden-cli
        bitwarden-menu
      ];
    };

  flake.homeModules.sops =
    { osConfig, ... }:
    let
      secretsPath = builtins.toString inputs.nix-secrets;
    in
    {
      sops = {
        # This is the dev access key and needs to have been copied to this location on the host
        age.keyFile = "/home/${osConfig.primaryUser.username}/.config/sops/age/keys.txt";

        defaultSopsFile = "${secretsPath}/secrets.yaml";
        validateSopsFiles = false;

        secrets = {
          "private_keys/${osConfig.primaryUser.username}" = {
            path = "/home/${osConfig.primaryUser.username}/.ssh/id_ed25519";
          };
        };
      };
    };
}
