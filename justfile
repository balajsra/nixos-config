default:
    @just --list

secrets-update:
    nix flake update --flake . nix-secrets

git-intent-to-add:
    git add -N .

flake-update:
    nix flake update --flake .

rebuild-test target='$(hostname)': git-intent-to-add
    @echo "Testing {{ target }}"
    nixos-rebuild dry-activate --flake .#{{ target }} --show-trace --sudo

rebuild-boot target='$(hostname)': git-intent-to-add
    @echo "Building {{ target }} for next boot"
    nixos-rebuild boot --flake .#{{ target }} --show-trace --sudo

rebuild-switch target='$(hostname)': git-intent-to-add
    @echo "Building and switching to {{ target }}"
    nixos-rebuild switch --flake .#{{ target }} --show-trace --sudo
