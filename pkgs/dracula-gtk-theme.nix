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

    # Copy the repository source into the theme path
    cp -r . "$THEME_DIR"

    # Copy Kvantum theme assets if present
    if [ -d "kde/kvantum" ]; then
      mkdir -p "$out/share/Kvantum"
      cp -r kde/kvantum/* "$out/share/Kvantum/" 2>/dev/null || true
    fi

    # Ensure gtk-3.0 and gtk-4.0 have fallback assets if upstream omits them
    if [ -d "$THEME_DIR/assets" ]; then
      for version in gtk-2.0 gtk-3.0 gtk-4.0; do
        if [ -d "$THEME_DIR/$version" ] && [ ! -d "$THEME_DIR/$version/assets" ]; then
          cp -r "$THEME_DIR/assets" "$THEME_DIR/$version/assets"
        fi
      done
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
