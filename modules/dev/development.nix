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
          # Wrap existing fish_greeting if it hasn't been wrapped yet
          if functions -q fish_greeting; and not functions -q __base_fish_greeting
            functions -c fish_greeting __base_fish_greeting

            function fish_greeting
              if not set -q DEVENV_ROOT; and not set -q DEVENV_STATE; and not set -q DIRENV_DIR
                __base_fish_greeting
              end
            end
          end

          # Only run devenv hook in top-level shells, not inside devenv subshells
          if not set -q DEVENV_ROOT
            devenv hook fish | source
          end
        '';
      };
    };
}
