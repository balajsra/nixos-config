{ self, inputs, ... }:

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
    ];
  };

  flake.nixosModules.sops =
    { pkgs, inputs, ... }:
    {
      environment.systemPackages = with pkgs; [
        age
        sops
        ssh-to-age
        mkpasswd
      ];
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
}
