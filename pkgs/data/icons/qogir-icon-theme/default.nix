{ lib
, stdenvNoCC
, fetchFromGitHub
, gitUpdater
, gtk3
, hicolor-icon-theme
, jdupes
, colorVariants ? [] # default is all
, themeVariants ? [] # default is all
}:

let
  pname = "qogir-icon-theme";

in
lib.checkListOfEnum "${pname}: color variants" [ "standard" "dark" "all" ] colorVariants
lib.checkListOfEnum "${pname}: theme variants" [ "default" "manjaro" "ubuntu" "all" ] themeVariants

stdenvNoCC.mkDerivation rec {
  inherit pname;
  version = "2022-10-08";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = version;
    sha256 = "sha256-BZhZyPnmiS5mxJp4/QnE7bTynB/cZ0QsUKFMhyd/Ox4=";
  };

  nativeBuildInputs = [ gtk3 jdupes ];

  propagatedBuildInputs = [ hicolor-icon-theme ];

  dontDropIconThemeCache = true;

  # These fixup steps are slow and unnecessary.
  dontPatchELF = true;
  dontRewriteSymlinks = true;

  postPatch = ''
    patchShebangs install.sh
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons

    name= ./install.sh \
      ${lib.optionalString (themeVariants != []) ("--theme " + builtins.toString themeVariants)} \
      ${lib.optionalString (colorVariants != []) ("--color " + builtins.toString colorVariants)} \
      --dest $out/share/icons

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    description = "Flat colorful design icon theme";
    homepage = "https://github.com/vinceliuice/Qogir-icon-theme";
    license = with licenses; [ gpl3Only ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo ];
  };
}
