{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vkbasalt
    vkbasalt-cli
  ];
}
