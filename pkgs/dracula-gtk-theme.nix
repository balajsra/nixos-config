{
  stdenv,
  fetchFromGitHub,
  lib,
}:

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

    mkdir -p $out/share/themes/Dracula
    mkdir -p $out/share/Kvantum

    # Copy root theme files
    cp -r assets gtk-2.0 gtk-3.0 gtk-4.0 index.theme $out/share/themes/Dracula/

    # Ensure assets are present inside gtk-3.0 and gtk-4.0 directories as well
    cp -r assets $out/share/themes/Dracula/gtk-3.0/assets 2>/dev/null || true
    cp -r assets $out/share/themes/Dracula/gtk-4.0/assets 2>/dev/null || true

    if [ -d src/Kvantum ]; then
      cp -r src/Kvantum/* $out/share/Kvantum/
    elif [ -d Kvantum ]; then
      cp -r Kvantum/* $out/share/Kvantum/
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dracula GTK theme";
    homepage = "https://draculatheme.com/gtk";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
