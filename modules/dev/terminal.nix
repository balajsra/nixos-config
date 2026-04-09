{ self, config, ... }:

{
  flake.homeModules.terminal =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.shell
        self.homeModules.shell-prompt
        self.homeModules.terminal-emulator
      ];
    };

  flake.homeModules.shell =
    { pkgs, config, ... }:
    {
      programs.bash = {
        enable = true;
        shellAliases = {
          ns-switch = "git -C ${config.primaryUser.nixosConfigPath} add -N . && nixos-rebuild switch --flake ${config.primaryUser.nixosConfigPath}#$(hostname) --show-trace --sudo";
          ns-boot = "git -C ${config.primaryUser.nixosConfigPath} add -N . && nixos-rebuild boot --flake ${config.primaryUser.nixosConfigPath}#$(hostname) --show-trace --sudo";
          ns-test = "git -C ${config.primaryUser.nixosConfigPath} add -N . && nixos-rebuild dry-activate --flake ${config.primaryUser.nixosConfigPath}#$(hostname) --show-trace --sudo";
          ns-update = "nix flake update --flake ${config.primaryUser.nixosConfigPath}";
        };
      };
      home.packages = with pkgs; [
        bash-completion
      ];
      programs.ghostty.enableBashIntegration = true;

      # https://nixos.wiki/wiki/Fish
      programs.fish.enable = true;
      programs.ghostty.enableFishIntegration = true;
      xdg.configFile."fish".enable = false;
      xdg.configFile."fish".source =
        config.lib.file.mkOutOfStoreSymlink "${config.primaryUser.dotfilesPath}/fish/.config/fish";
    };

  flake.homeModules.shell-prompt =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        krabby
      ];

      # https://wiki.nixos.org/wiki/Starship
      programs.starship.enable = true;
      xdg.configFile."starship.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.primaryUser.dotfilesPath}/starship/.config/starship.toml";

      # https://wiki.nixos.org/wiki/Tmux
      programs.tmux.enable = true;
      home.file.".tmux".source =
        config.lib.file.mkOutOfStoreSymlink "${config.primaryUser.dotfilesPath}/tmux/.tmux";
      home.file.".tmux.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${config.primaryUser.dotfilesPath}/tmux/.tmux.conf";
    };

  flake.homeModules.terminal-emulator =
    { config, ... }:
    {
      programs.foot = {
        enable = true;
        server.enable = true;
      };
      xdg.configFile."foot".source =
        config.lib.file.mkOutOfStoreSymlink "${config.primaryUser.dotfilesPath}/foot/.config/foot";

      # https://wiki.nixos.org/wiki/Ghostty
      programs.ghostty.enable = true;
      xdg.configFile."ghostty".source =
        config.lib.file.mkOutOfStoreSymlink "${config.primaryUser.dotfilesPath}/ghostty/.config/ghostty";
    };
}
