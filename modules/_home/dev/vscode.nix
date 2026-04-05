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
}
