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
                name = "cryptroot";
                # disable settings.keyFile if you want to use interactive password entry
                # passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  # keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
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
                    "@snapshots" = {
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
