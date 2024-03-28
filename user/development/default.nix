{ config, lib, pkgs, userSettings, ... }:

{
  imports = [
    ./vscode.nix
    ./cli.nix
  ];
}
