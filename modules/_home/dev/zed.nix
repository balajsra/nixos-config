{
  # https://wiki.nixos.org/wiki/Zed
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "html"
      "git-firefly"
      "xml"
      "latex"
      "csv"
      "vscode-icons"
      "ini"
    ];
    installRemoteServer = true;
  };
}
