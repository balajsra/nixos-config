{
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
}
