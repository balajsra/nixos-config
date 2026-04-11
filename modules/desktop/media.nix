{ self, ... }:

{
  flake.homeModules.media = {
    imports = [
      self.homeModules.media-scraper
      self.homeModules.video
      self.homeModules.audio
      self.homeModules.image
      self.homeModules.media-management
    ];
  };

  flake.homeModules.media-scraper =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ani-cli
        yt-dlp
      ];
    };

  flake.homeModules.video =
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
        fladder
      ];
    };

  flake.homeModules.audio =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        feishin
        pocket-casts
      ];
    };

  flake.homeModules.image =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gimp
      ];
    };

  flake.homeModules.media-management =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        picard
      ];
    };
}
