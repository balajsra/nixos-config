{ vars, ... }:
let
    nixosConfigPath = "/home/${vars.username}/.config/nixos";
in
{
    programs.bash = {
        enable = true;
        shellAliases = {
            git-graph = "git log --all --decorate --oneline --graph";
            nix-switch = "sudo nixos-rebuild switch --flake ${nixosConfigPath}#$(hostname) --show-trace";
            nix-update = "pushd ${nixosConfigPath} && sudo nix flake update && popd";
        };
    };
}
