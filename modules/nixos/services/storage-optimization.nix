{
    # Storage Optimization: https://nixos.wiki/wiki/Storage_optimization

    # Optimising the store
    nix.optimise = {
        automatic = true;
        dates = [ "01:00" ]; # Daily at 1:00 AM (or next boot)
    };

    # Garbage Collection
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
    };
}
