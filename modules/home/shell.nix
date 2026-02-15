{ vars, ... }:
let
    nixosConfigPath = "/home/${vars.username}/.config/nixos";
in
{
    programs.bash = {
        enable = true;
        shellAliases = {
            git-graph = "git log --all --decorate --oneline --graph";
            nix-switch = "git -C ${nixosConfigPath} add -N . && nixos-rebuild switch --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
            nix-update = "nix flake update --flake ${nixosConfigPath}";
        };
    };
}
