{ self, ... }:

{
  flake.homeModules.development = {
    imports = [
      self.homeModules.devenv
    ];
  };

  flake.homeModules.devenv =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        devenv
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

      xdg.configFile."secretspec/config.toml".source =
        (pkgs.formats.toml { }).generate "secretspec-config"
          {
            defaults = {
              provider =
                if osConfig.features.security.keepass.enable then
                  "keepass_vault"
                else if osConfig.features.security.bitwarden.enable then
                  "bitwarden_vault"
                else
                  "null_vault";
              profile = "development";

              providers = {
                keepass_vault = {
                  uri = "kdbx:/data/${osConfig.primaryUser.username}/Vault/Vault.kdbx";
                  credentials.password = "keyring";
                };
                bitwarden_vault = {
                  uri = "bw://";
                };
                null_vault = {
                  uri = "null://";
                };
              };
            };
          };
    };
}
