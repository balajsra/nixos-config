{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "dracula-gtk-theme";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "dracula";
    repo = "gtk";
    rev = "master";
    hash = "sha256-gbotOIGG55oqQZZNDkc9s5fPXvJQr+YHqxt5ZWS5bF8=";
  };

  installPhase = ''
    runHook preInstall

    # 1. Prepare output directories
    mkdir -p $out/share/themes/Dracula
    mkdir -p $out/share/Kvantum

    # 2. Copy GTK theme files into the GTK theme directory
    cp -r assets gtk-2.0 gtk-3.0 gtk-4.0 index.theme $out/share/themes/Dracula/

    # 3. Copy Kvantum files into the Kvantum directory (if they exist in the repo)
    if [ -d src/Kvantum ]; then
      cp -r src/Kvantum/* $out/share/Kvantum/
    elif [ -d Kvantum ]; then
      cp -r Kvantum/* $out/share/Kvantum/
    fi

    runHook postInstall
  '';
}
