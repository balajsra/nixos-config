default:
    @just --list

git-intent-to-add:
    git add -N .

flake-update input="":
    #!/usr/bin/env bash
    if [ -z "{{ input }}" ]; then
        echo "Updating all flake inputs..."
        nix flake update --flake .
    else
        echo "Updating flake input: {{ input }}..."
        nix flake update --flake . "{{ input }}"
    fi

rebuild-test target='$(hostname)': git-intent-to-add
    @echo "Testing {{ target }}"
    nixos-rebuild dry-activate --flake .#{{ target }} --show-trace --sudo

rebuild-boot target='$(hostname)': git-intent-to-add
    @echo "Building {{ target }} for next boot"
    nixos-rebuild boot --flake .#{{ target }} --show-trace --sudo

rebuild-switch target='$(hostname)': git-intent-to-add
    @echo "Building and switching to {{ target }}"
    nixos-rebuild switch --flake .#{{ target }} --show-trace --sudo
