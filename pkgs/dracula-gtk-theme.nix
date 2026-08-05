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

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    THEME_DIR="$out/share/themes/Dracula"
    mkdir -p "$THEME_DIR"
    mkdir -p "$out/share/Kvantum"

    cp -r * "$THEME_DIR/"

    # Link/Copy assets for GTK3/4 relative lookup
    if [ -d "$THEME_DIR/assets" ]; then
      cp -r "$THEME_DIR/assets" "$THEME_DIR/gtk-3.0/" 2>/dev/null || true
      cp -r "$THEME_DIR/assets" "$THEME_DIR/gtk-4.0/" 2>/dev/null || true
    fi

    if [ -d "$THEME_DIR/src/Kvantum" ]; then
      cp -r "$THEME_DIR/src/Kvantum/"* $out/share/Kvantum/
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
