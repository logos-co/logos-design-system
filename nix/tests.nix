{ pkgs, common }:

# QML unit tests — builds the LogosDesignSystemTests binary, runs it via
# ctest in the check phase, then installs the binary plus the .qml test
# files for ad-hoc post-install runs.
pkgs.stdenv.mkDerivation rec {
  pname = "logos-design-system-tests";
  version = "1.0.0";

  inherit (common) src nativeBuildInputs buildInputs preConfigure;

  cmakeFlags = common.baseCmakeFlags ++ [
    "-DLOGOS_DS_BUILD_TESTS=ON"
  ];

  configurePhase = ''
    runHook preConfigure
    cmake -S . -B build $cmakeFlags
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    cmake --build build --target LogosDesignSystemTests
    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    export QT_QPA_PLATFORM=offscreen
    # During checkPhase the test binary is unwrapped — wrapQtAppsHook only
    # runs in fixupPhase. Point QML_IMPORT_PATH at Qt's QML modules so imports
    # like QtTest / QtQuick.Window resolve.
    export QML_IMPORT_PATH="${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:$QML_IMPORT_PATH"
    export QML2_IMPORT_PATH="$QML_IMPORT_PATH"
    ctest --test-dir build --output-on-failure
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp build/tests/LogosDesignSystemTests $out/bin/

    # Ship .qml test files + the bundled test PNG so the binary is runnable
    # post-install (path resolution in main.cpp falls back to <bin>/../share/...).
    mkdir -p $out/share/logos-design-system-tests
    cp ${src}/tests/tst_*.qml $out/share/logos-design-system-tests/
    cp ${src}/tests/test-icon.png $out/share/logos-design-system-tests/

    # Logos.Theme/.Controls/.Icons are STATIC-linked into the test binary via
    # logos_design_system; no lib/Logos copy needed.

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "QML unit tests for the Logos Design System";
    mainProgram = "LogosDesignSystemTests";
    platforms = platforms.unix;
  };
}
