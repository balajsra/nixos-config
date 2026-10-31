{
  stdenv,
  src,
  lib,
}:

stdenv.mkDerivation {
  pname = "fallout-grub-theme";
  version = "unstable";

  inherit src;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = with lib; {
    description = "Fallout GRUB Theme";
    homepage = "https://github.com/shvchk/fallout-grub-theme";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
