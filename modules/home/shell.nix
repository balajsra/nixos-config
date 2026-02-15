{ vars, ... }:
let
    nixosConfigPath = "/home/${vars.username}/.config/nixos";
in
{
    programs.bash = {
        enable = true;
        shellAliases = {
            git-graph = "git log --all --decorate --oneline --graph";
            nix-switch = "nixos-rebuild switch --flake ${nixosConfigPath}#$(hostname) --show-trace --sudo";
            nix-update = "pushd ${nixosConfigPath} && nix flake update && popd";
        };
    };
}
