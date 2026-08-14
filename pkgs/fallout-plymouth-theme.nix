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
    runHook preInstall

    target_dir="$out/share/plymouth/themes/fallout"
    mkdir -p "$target_dir"
    cp -r * "$target_dir/"
    cd "$target_dir"

    # Patch absolute paths in fallout.plymouth to point to $out
    substituteInPlace fallout.plymouth \
      --replace-fail "/usr/share/plymouth/themes/fallout" "$target_dir"

    # Inject missing global declarations at the top of fallout.script
    #   - RotatedImageCache = []; prevents array indexing runtime crash
    #   - motif definitions prevent null reference crashes in callbacks
    sed -i '1s/^/RotatedImageCache = [];\nmotif = [];\nmotif.sprite = SpriteNew();\nmotif.opacity = 0;\n/' fallout.script

    # Comment out lingering motif calls that attempt to set properties on null
    sed -i 's/motif\.sprite\.SetOpacity/\/\/ motif.sprite.SetOpacity/g' fallout.script

    runHook postInstall
  '';

  meta = with lib; {
    description = "Fallout Plymouth Theme";
    homepage = "https://store.kde.org/p/1259515";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
