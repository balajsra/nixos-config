{ pkgs, vars, ... }:
let
  nixosConfigPath = "/home/${vars.username}/.config/nixos";
in
{
  programs.bash = {
    enable = true;
    shellAliases = {
      git-graph = "git log --all --decorate --oneline --graph";
      ns-switch = "git -C ${nixosConfigPath} add -N . && nixos-rebuild switch --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
      ns-boot = "git -C ${nixosConfigPath} add -N . && nixos-rebuild boot --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
      ns-test = "git -C ${nixosConfigPath} add -N . && nixos-rebuild dry-activate --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
      ns-update = "nix flake update --flake ${nixosConfigPath}";
    };
  };

  home.packages = with pkgs; [
    bash-completion
    krabby
  ];
}
