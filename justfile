# Set /run/wrappers/bin at the front of PATH for all recipes to fix issue with VS Code integrated terminal
# when using devenv extension
export PATH := "/run/wrappers/bin:" + env('PATH')

export SECRETS_FILE := "secrets.yaml"
export SSH_HOST_KEY := "/etc/ssh/ssh_host_ed25519_key"

default:
    @just --list

build-setup:
    #!/usr/bin/env bash
    if [ ! -f "{{ SECRETS_FILE }}" ]; then
        echo "{{ SECRETS_FILE }} not found. Generating..."
        just generate-secrets
    else
        echo "{{ SECRETS_FILE }} exists. Skipping generation."
    fi
    git add -N .

generate-secrets:
    #!/usr/bin/env bash
    echo "Unlocking Bitwarden session..."
    export BW_SESSION=$(bw unlock --raw)

    echo "Syncing Bitwarden vault..."
    bw sync

    echo "Deriving Age key from system SSH host key..."
    AGE_KEY=$(ssh-to-age -i {{ SSH_HOST_KEY }}.pub)

    echo "Building and encrypting {{ SECRETS_FILE }}..."
    secretspec export --format json | yq -y '.' | sops --input-type yaml --encrypt --age "${AGE_KEY}" /dev/stdin > {{ SECRETS_FILE }}

    echo "Successfully generated and encrypted {{ SECRETS_FILE }}"

decrypt-secrets :
    #!/usr/bin/env bash
    SOPS_AGE_KEY=$(sudo ssh-to-age -private-key -i {{ SSH_HOST_KEY }}) sops --decrypt {{ SECRETS_FILE }}

flake-update input="":
    #!/usr/bin/env bash
    if [ -z "{{ input }}" ]; then
        echo "Updating all flake inputs..."
        nix flake update --flake .
    else
        echo "Updating flake input: {{ input }}..."
        nix flake update --flake . "{{ input }}"
    fi

rebuild-test target='$(hostname)': build-setup
    @echo "Testing {{ target }}"
    nixos-rebuild dry-activate \
        --flake .#{{ target }} \
        --show-trace \
        --verbose \
        --sudo

rebuild-test-all:
    #!/usr/bin/env bash
    set -euxo pipefail

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

rebuild-boot target='$(hostname)': build-setup
    @echo "Building {{ target }} for next boot"
    nixos-rebuild boot \
        --flake .#{{ target }} \
        --sudo

rebuild-switch target='$(hostname)': build-setup
    @echo "Building and switching to {{ target }}"
    nixos-rebuild switch \
        --flake .#{{ target }} \
        --sudo
