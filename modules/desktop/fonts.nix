{ self, lib, ... }:

{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.fonts-base
        self.nixosModules.fonts-nerd
        self.nixosModules.fonts-emojis
        self.nixosModules.fonts-japanese
        self.nixosModules.fonts-korean
      ];
    };

  flake.nixosModules.fonts-base =
    { pkgs, config, ... }:
    {
      config = lib.mkIf (config.features.fonts.enable) {
        # https://wiki.nixos.org/wiki/Fonts
        fonts.fontconfig.useEmbeddedBitmaps = true;

        fonts.packages = with pkgs; [
          corefonts
        ];
      };
    };

  flake.nixosModules.fonts-nerd =
    { pkgs, config, ... }:
    {
      config = lib.mkIf (config.features.fonts.nerd.enable) {
        fonts.packages = with pkgs; [
          nerd-fonts.droid-sans-mono
          nerd-fonts.fira-code
          nerd-fonts.fira-mono
          nerd-fonts.jetbrains-mono
          nerd-fonts.monaspace
          nerd-fonts.noto
          nerd-fonts.ubuntu
          nerd-fonts.ubuntu-sans
          nerd-fonts.ubuntu-mono
        ];
      };
    };

  flake.nixosModules.fonts-emojis =
    { pkgs, config, ... }:
    {
      config = lib.mkIf (config.features.fonts.emojis.enable) {
        fonts.packages = with pkgs; [
          noto-fonts-color-emoji
        ];
      };
    };

  flake.nixosModules.fonts-japanese =
    { pkgs, config, ... }:
    {
      config = lib.mkIf (config.features.fonts.japanese.enable) {
        fonts.packages = with pkgs; [
          mplus-outline-fonts.githubRelease
          ipafont
        ];
      };
    };

  flake.nixosModules.fonts-korean =
    { pkgs, config, ... }:
    {
      config = lib.mkIf (config.features.fonts.korean.enable) {
        fonts.packages = with pkgs; [
          baekmuk-ttf
          noto-fonts-cjk-sans
        ];
      };
    };
}
