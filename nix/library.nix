{ pkgs, common }:

# STATIC QML modules for Logos.Theme / .Icons / .Controls, plus the CMake
# package config that downstream apps (logos-basecamp, logos-standalone-app)
# consume via `find_package(LogosDesignSystem CONFIG)` and link as
# `Logos::DesignSystem`. Bytecode + assets are embedded into the STATIC libs,
# so no loose-file `lib/Logos/*.qml` install exists at runtime — nothing for
# Qt's QML disk cache to go stale across app upgrades.
pkgs.stdenv.mkDerivation rec {
  pname = "logos-design-system";
  version = "1.0.0";

  inherit (common) src nativeBuildInputs buildInputs preConfigure;

  cmakeFlags = common.baseCmakeFlags;

  # Standard configure/build/install — supersedes the previous "just cp -r
  # the source tree into $out/lib/Logos" install path.
  configurePhase = ''
    runHook preConfigure
    cmake -S . -B build $cmakeFlags -DCMAKE_INSTALL_PREFIX=$out
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cmake --install build
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Logos Design System - Qt/QML themes, colors, typography";
    platforms = platforms.unix;
  };
}
