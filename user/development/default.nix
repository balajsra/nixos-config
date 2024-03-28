{ config, lib, pkgs, ... }:

{
  imports = [
    ./vscode.nix
    ./doom-emacs.nix
  ];
}
