{ self, config, ... }:
let
  dotfilesPath = "${config.home.homeDirectory}/.config/nixos/dotfiles";
in
{
  flake.nixosModules.editor = {
    imports = [
      self.nixosModules.vim
    ];
  };

  flake.homeModules.editor = {
    imports = [
      self.homeModules.vim
      self.homeModules.vscode
    ];
  };

  flake.nixosModules.vim =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vim
      ];
    };

  flake.homeModules.vim = {
    programs.vim = {
      enable = true;
    };

    home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vim/.vimrc";

    home.file.".vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vim/.vim";
  };

  flake.homeModules.vscode =
    { pkgs, ... }:
    {
      programs.vscode = {
        enable = true;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
          jnoortheen.nix-ide
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

  flake.homeModules.zed = {
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
}
