{ self, ... }:

{
  flake.homeModules.development = {
    imports = [
      self.homeModules.nix-development
    ];
  };

  flake.homeModules.nix-development =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nixd
        nixfmt
      ];
    };
}
