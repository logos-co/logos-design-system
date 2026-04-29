{ pkgs, common }:

# The storybook host app — browses components + token catalog. Builds the
# LogosStorybook target, ships it with the page QML files and the design-
# system QML modules so the binary is self-contained at runtime.
pkgs.stdenv.mkDerivation rec {
  pname = "logos-storybook";
  version = "1.0.0";

  inherit (common) src nativeBuildInputs buildInputs preConfigure;

  cmakeFlags = common.baseCmakeFlags ++ [
    "-DLOGOS_DS_BUILD_STORYBOOK=ON"
  ];

  configurePhase = ''
    runHook preConfigure
    cmake -S . -B build $cmakeFlags
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build --target LogosStorybook
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp build/storybook/LogosStorybook $out/bin/

    # Storybook pages
    mkdir -p $out/share/logos-storybook/pages
    cp ${src}/storybook/pages/*.qml $out/share/logos-storybook/pages/

    # Logos.Theme + Logos.Controls (source layout matches import path)
    mkdir -p $out/lib
    cp -r ${src}/src/qml/Logos $out/lib/

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Browse and preview Logos Design System components";
    mainProgram = "LogosStorybook";
    platforms = platforms.unix;
  };
}
