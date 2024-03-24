let
  installDisk = "sda";
  bootPartitionSize = "512M";
  swapfileSize = "34G";
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/" + installDisk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = bootPartitionSize;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                # passwordFile = "/tmp/secret.key"; # Interactive
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "/.snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = swapfileSize;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
