{ config, lib, pkgs, userSettings, ... }:

{
  environment.systemPackages = with pkgs; [
    rclone
  ];
}
