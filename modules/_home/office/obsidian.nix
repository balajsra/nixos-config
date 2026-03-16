{ pkgs, ... }:

{
  # https://wiki.nixos.org/wiki/Obsidian
  programs.obsidian = {
    enable = true;
    cli.enable = true;
  };

  # TODO: Configure obsidian with Nix
}
