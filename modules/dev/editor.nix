{ self, config, ... }:

{
  flake.nixosModules.editor = {
    imports = [
      self.nixosModules.nano
      self.nixosModules.vim
    ];
  };

  flake.homeModules.editor =
    { osConfig, ... }:
    {
      imports = [
        self.homeModules.vim
        self.homeModules.vscode
        self.homeModules.zed
      ];

      home.sessionVariables = {
        EDITOR = osConfig.features.editor.terminal;
        VISUAL = osConfig.features.editor.gui;
      };
    };

  flake.nixosModules.nano =
    { config, pkgs, ... }:
    {
      programs.nano.enable = config.features.editor.nano.enable;
    };

  flake.nixosModules.vim =
    { config, pkgs, ... }:
    {
      programs.vim.enable = config.features.editor.vim.enable;
    };

  flake.homeModules.vim =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.editor.vim.enable) {
        programs.vim = {
          enable = true;
        };

        home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vim/.vimrc";
        home.file.".vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vim/.vim";
      };
    };

  flake.homeModules.vscode =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.editor.vscode.enable) {
        programs.vscode = {
          enable = true;
          profiles.default.extensions = with pkgs.vscode-extensions; [
            vscodevim.vim
            jnoortheen.nix-ide
            nefrob.vscode-just-syntax
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            ms-vscode.remote-explorer
          ];
        };

        xdg.configFile."Code/User/keybindings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vscode/.config/Code/User/keybindings.json";
        xdg.configFile."Code/User/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vscode/.config/Code/User/settings.json";
      };
    };

  flake.homeModules.zed =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.editor.zed.enable) {
        # https://wiki.nixos.org/wiki/Zed
        programs.zed-editor = {
          enable = true;
          extensions = [
            "nix"
            "toml"
            "html"
            "xml"
            "latex"
            "csv"
            "vscode-icons"
            "ini"
          ];
          installRemoteServer = true;
        };
      };
    };
}
