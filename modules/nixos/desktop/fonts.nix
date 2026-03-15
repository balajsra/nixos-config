{ pkgs, ... }:

{
  # https://nixos.wiki/wiki/Fonts

  fonts.fontconfig.useEmbeddedBitmaps = true;

  fonts.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    nerd-fonts.noto
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-sans
    nerd-fonts.ubuntu-mono

    # Emojis and Symbols
    noto-fonts-color-emoji

    # Japanese
    mplus-outline-fonts.githubRelease
    ipafont

    # Korean
    baekmuk-ttf
    noto-fonts-cjk-sans

    # Other
    corefonts
  ];
}
