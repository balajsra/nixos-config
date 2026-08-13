{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation {
  pname = "fallout-grub-theme";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "shvchk";
    repo = "fallout-grub-theme";
    rev = "master";
    hash = "sha256-dNRLM9tQjWOyi3s4Q2er5Xn2bpG/yQ/D/+F/lfYXrs8=";
  };

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
