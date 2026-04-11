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
    {
      pkgs,
      config,
      osConfig,
      ...
    }:
    let
      nixosConfigPath = toString osConfig.primaryUser.nixosConfigPath;
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      programs.bash = {
        enable = true;
        shellAliases = {
          ns-switch = "git -C ${nixosConfigPath} add -N . && nixos-rebuild switch --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
          ns-boot = "git -C ${nixosConfigPath} add -N . && nixos-rebuild boot --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
          ns-test = "git -C ${nixosConfigPath} add -N . && nixos-rebuild dry-activate --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
          ns-update = "nix flake update --flake ${nixosConfigPath}";
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
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish";
    };

  flake.homeModules.shell-prompt =
    {
      pkgs,
      config,
      osConfig,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      home.packages = with pkgs; [
        krabby
      ];

      # https://wiki.nixos.org/wiki/Starship
      programs.starship.enable = true;
      xdg.configFile."starship.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/starship/.config/starship.toml";

      # https://wiki.nixos.org/wiki/Tmux
      programs.tmux.enable = true;
      home.file.".tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.tmux";
      home.file.".tmux.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.tmux.conf";
    };

  flake.homeModules.terminal-emulator =
    { config, osConfig, ... }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      programs.foot = {
        enable = true;
        server.enable = true;
      };
      xdg.configFile."foot".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/foot/.config/foot";

      # https://wiki.nixos.org/wiki/Ghostty
      programs.ghostty.enable = true;
      xdg.configFile."ghostty".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ghostty/.config/ghostty";
    };
}
