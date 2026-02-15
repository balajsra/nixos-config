{ pkgs, vars, ... }:

{
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${vars.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
    };

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
        tree
        nixd
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Do not change, this is a safety anchor to prevent
    # system from breaking or losing data during an upgrade
    system.stateVersion = "25.11";
}
