{ self, ... }:

{
  flake.homeModules.security = {
    imports = [
      self.homeModules.bitwarden
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
