{ pkgs, ... }:

{
  # https://wiki.nixos.org/wiki/Thunderbird
  home.packages = with pkgs; [
    thunderbird
  ];

  # https://wiki.nixos.org/wiki/Default_applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/mailto" = "thunderbird.desktop";
    };
  };

  # TODO: Use home manager to configure Thunderbird
}
