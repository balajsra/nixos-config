{ self, ... }:

{
  flake.homeModules.development = {
    imports = [
      self.homeModules.nix-development
    ];
  };

  flake.homeModules.nix-development =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        nixd
        nixfmt
        devenv
        just
        just-lsp
      ];

      programs.bash = lib.mkIf osConfig.features.terminal.bash.enable {
        bashrcExtra = ''
          # Devenv Auto Activation
          eval "$(devenv hook bash)"
        '';
      };

      programs.fish = lib.mkIf osConfig.features.terminal.fish.enable {
        interactiveShellInit = ''
          # Devenv Auto Activation
          devenv hook fish | source
        '';
      };
    };
}
