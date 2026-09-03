# Set /run/wrappers/bin at the front of PATH for all recipes to fix issue with VS Code integrated terminal
# when using devenv extension
export PATH := "/run/wrappers/bin:" + env('PATH')

export SECRETS_FILE_DIR := "/etc/nixos"
export SECRETS_FILE := "${SECRETS_FILE_DIR}/secrets.yaml"
export SSH_HOST_KEY := "/etc/ssh/ssh_host_ed25519_key"
export AGE_KEY_DIR := env('HOME') + "/.config/sops/age"
export AGE_KEY_FILE := "${AGE_KEY_DIR}/keys.txt"

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

    # Stage all untracked changes for Nix evaluation
    git add -N .

generate-secrets:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Unlocking Bitwarden session..."
    export BW_SESSION=$(bw unlock --raw)

    echo "Syncing Bitwarden vault..."
    bw sync

    echo "Check that all secretspec secrets are available..."
    secretspec check

    echo "Generating user age key..."
    mkdir -p "{{ AGE_KEY_DIR }}"
    age-keygen -pq > "{{ AGE_KEY_FILE }}"
    chmod 600 "{{ AGE_KEY_FILE }}"

    echo "Extracting host and user public age keys..."
    USER_AGE_KEY=$(age-keygen -y "{{ AGE_KEY_FILE }}")
    HOST_AGE_KEY=$(ssh-to-age -i {{ SSH_HOST_KEY }}.pub)

    echo "Exporting secretspec to JSON..."
    RAW_JSON=$(secretspec export --format json)

    # Find all keys matching the PASSWORDS__* prefix
    PASSWORD_KEYS=$(echo "$RAW_JSON" | jq -r 'keys[] | select(startswith("PASSWORDS__"))')

    # Hash each matching key with mkpasswd
    for KEY in $PASSWORD_KEYS; do
        PLAIN_VAL=$(echo "$RAW_JSON" | jq -r --arg k "$KEY" '.[$k] // empty')
        if [ -n "$PLAIN_VAL" ]; then
            echo "Hashing password key: $KEY"
            HASHED_VAL=$(printf '%s' "$PLAIN_VAL" | mkpasswd -m sha-512 -s)
            RAW_JSON=$(echo "$RAW_JSON" | jq --arg k "$KEY" --arg v "$HASHED_VAL" '.[$k] = $v')
        fi
    done

    echo "Building and encrypting {{ SECRETS_FILE }} for both host and user keys..."
    TMP_SECRETS=$(mktemp)
    trap 'rm -f "${TMP_SECRETS}"' EXIT
    echo "$RAW_JSON" | yq -y '.' | sops --input-type yaml --encrypt --age "${HOST_AGE_KEY},${USER_AGE_KEY}" /dev/stdin > ${TMP_SECRETS}
    sudo mkdir -p {{ SECRETS_FILE_DIR }}
    sudo install -m 0644 -o root -g root "${TMP_SECRETS}" {{ SECRETS_FILE }}

    echo "Successfully generated and encrypted {{ SECRETS_FILE }}"

decrypt-secrets :
    #!/usr/bin/env bash
    SOPS_AGE_KEY_FILE="{{ AGE_KEY_FILE }}" sops --decrypt {{ SECRETS_FILE }}

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
