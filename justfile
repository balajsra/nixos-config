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

rebuild-test-all:
    #!/usr/bin/env bash
    # Get host names from files in modules/hosts
    hosts=$(ls modules/hosts/*.nix 2>/dev/null | xargs -n 1 basename -s .nix | grep -v "variables")

    # Protect against no defined hosts (shouldn't happen)
    if [ -z "$hosts" ]; then
        echo "No hosts found in modules/hosts/"
        exit 1
    fi

    # Run existing `rebuild-test` recipe against each host
    for host in $hosts; do
        echo "========================================"
        echo "Running rebuild-test for host: $host"
        echo "========================================"
        just rebuild-test "$host"
    done

rebuild-boot target='$(hostname)': git-intent-to-add
    @echo "Building {{ target }} for next boot"
    nixos-rebuild boot --flake .#{{ target }} --show-trace --sudo

rebuild-switch target='$(hostname)': git-intent-to-add
    @echo "Building and switching to {{ target }}"
    nixos-rebuild switch --flake .#{{ target }} --show-trace --sudo
