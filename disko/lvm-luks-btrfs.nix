{ lib, ... }:
let
    # --- Configuration Variables ---
    myDisks = [ "/dev/sdb" "/dev/sda" ];
    swapSize = "2G";
    # -------------------------------

    # Helper to determine if a disk is the "primary" boot disk
    isFirstDisk = dev: dev == (builtins.head myDisks);
in
{
    disko.devices = {
        disk = lib.genAttrs myDisks (dev: {
            device = dev;
            type = "disk";
            content = {
                type = "gpt";
                partitions = {
                    # Partition 1: Boot (Only on the first disk)
                    boot = lib.mkIf (isFirstDisk dev) {
                        size = "1G";
                        type = "EF00";
                        content = {
                            type = "filesystem";
                            format = "vfat";
                            mountpoint = "/boot";
                            mountOptions = [ "umask=0077" ];
                        };
                    };

                    # Partition 2: LVM Physical Volume
                    lvm = {
                        size = "100%";
                        content = {
                            type = "lvm_pv";
                            vg = "vgroot";
                        };
                    };
                };
            };
        });

        lvm_vg.vgroot = {
            type = "lvm_vg";
            lvs = {
                lv_crypt_store = {
                    size = "100%FREE";
                    content = {
                        type = "luks";
                        name = "decrypted_root";
                        extraFormatArgs = [
                            "--type luks2"
                            "--cipher aes-xts-plain64"
                            "--key-size 512"
                            "--hash sha512"
                            "--pbkdf argon2id"
                            "--iter-time 5000" # 5 seconds of hashing derivation
                            "--use-random"
                        ];
                        settings = {
                            allowDiscards = true; # Recommended for SSDs/NVMe
                        };
                        content = {
                            type = "btrfs";
                            extraArgs = [ "-f" ];
                            subvolumes = {
                                "@" = { mountpoint = "/"; mountOptions = [ "compress=zstd" ]; };
                                "@home" = { mountpoint = "/home"; mountOptions = [ "compress=zstd" ]; };
                                "@nix" = { mountpoint = "/nix"; mountOptions = [ "compress=zstd" "noatime" ]; };
                                "@data" = { mountpoint = "/data"; mountOptions = [ "compress=zstd" ]; };
                                "@tmp" = { mountpoint = "/tmp"; };
                                "@var" = { mountpoint = "/var"; mountOptions = [ "compress=zstd" ]; };
                                "@snapshots" = { mountpoint = "/.snapshots"; mountOptions = [ "compress=zstd" ]; };
                                "@home_snapshots" = { mountpoint = "/home/.snapshots"; mountOptions = [ "compress=zstd" ]; };
                                "@swap" = {
                                    mountpoint = "/swap";
                                    # Swap on Btrfs should not be compressed
                                    mountOptions = [ "noatime" ];
                                    swap.swapfile.size = swapSize;
                                };
                            };
                        };
                    };
                };
            };
        };
    };
}
		
