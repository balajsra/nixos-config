let
  installDisk = "vda";
  bootPartitionSize = "512M";
  swapfileSize = "10G";
in {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/" + installDisk;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
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
                name = "cryptroot";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "@.snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" "discard=async" "space_cache=v2" "ssd" ];
                    };
                    "@swap" = {
                      mountpoint = "/swap";
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
