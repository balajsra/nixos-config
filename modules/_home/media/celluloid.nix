{ pkgs, ... }:

{
  # https://wiki.nixos.org/wiki/MPV
  programs.mpv = {
    enable = true;
    config = {
      profile = "high-quality";
      hwdec = "auto";
      sub-auto = "fuzzy";
      sub-bold = "yes";
    };
  };

  home.packages = with pkgs; [
    celluloid
  ];
}
