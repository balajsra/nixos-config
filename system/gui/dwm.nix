{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
    ./lightdm.nix
    ./x11.nix
  ];

  nixpkgs = {
    overlays = [
      (self: super: {
        dwm = super.dwm.overrideAttrs (oldattrs: {
          src = fetchGit {
            url = "https://gitea.sravanbalaji.com/sravan/dwm-flexipatch.git";
            rev = "23b55eaf9cd9c08d4c14f7957675ae056e358e32";
          };
          buildInputs = with pkgs; [
            xorg.libX11
            xorg.libXinerama
            xorg.libXft
            yajl
          ];
        });
      })
    ];
  };

  services.xserver.windowManager.dwm.enable = true;
  services.xserver.displayManager.defaultSession = "none+dwm";
}
