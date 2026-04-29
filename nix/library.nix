{ pkgs, common }:

# The QML library — what every downstream consumer depends on. Just installs
# Logos.Theme + Logos.Controls into $out/lib/Logos/. No compiled artifacts.
pkgs.stdenv.mkDerivation rec {
  pname = "logos-design-system";
  version = "1.0.0";

  inherit (common) src nativeBuildInputs buildInputs preConfigure;

  cmakeFlags = common.baseCmakeFlags;

  configurePhase = ''
    runHook preConfigure
    cmake -S . -B build $cmakeFlags
    runHook postConfigure
  '';

  # Pure file install — nothing to compile.
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Source layout already matches the QML import path (Logos/Theme,
    # Logos/Controls), so a single recursive copy suffices.
    mkdir -p $out/lib
    cp -r ${src}/src/qml/Logos $out/lib/

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Logos Design System - Qt/QML themes, colors, typography";
    platforms = platforms.unix;
  };
}
