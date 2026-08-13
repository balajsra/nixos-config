{
  stdenv,
  fetchFromGitHub,
  lib,
}:

stdenv.mkDerivation {
  pname = "fallout-plymouth-theme";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "balajsra";
    repo = "fallout-plymouth-theme";
    rev = "main";
    hash = "sha256-I15QnTUqyPm4rJKgisgrURzYeXs4mW5DIjiUAVVJHhE=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/fallout
    cp -r * $out/share/plymouth/themes/fallout/
    cd $out/share/plymouth/themes/fallout

    # Fix hardcoded path in .plymouth
    substituteInPlace fallout.plymouth \
      --replace-fail "/usr/share/plymouth/themes/fallout" "$out/share/plymouth/themes/fallout"
  '';

  meta = with lib; {
    description = "Fallout Plymouth Theme";
    homepage = "https://store.kde.org/p/1259515";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
