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

  # Required wherever the Qt wrapper hooks are absent (see nix/common.nix).
  dontWrapQtApps = true;

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
    # Probe both names and FAIL if neither is there. Naming only the unsuffixed
    # binary meant a mingw build -- which links LogosStorybook.exe -- died with
    # "cp: cannot stat 'build/storybook/LogosStorybook'" immediately after the
    # link step had succeeded.
    # Search the tree rather than hardcoding a directory: on Windows CMake puts
    # RUNTIME artifacts in the runtime output directory (the build root here) so
    # that executables and their DLLs end up side by side, while the ARCHIVE
    # artifact -- libLogosStorybook.dll.a -- stays in build/storybook/. Looking
    # only in build/storybook/ finds the import library and no binary.
    _sb=""
    for _cand in $(find build -maxdepth 3 -type f \
                     \( -name LogosStorybook -o -name LogosStorybook.exe \) 2>/dev/null); do
      _sb="$_cand"; break
    done
    if [ -z "$_sb" ]; then
      echo "Error: the LogosStorybook binary was not produced by the build" >&2
      ls -la build/storybook 2>&1 >&2 || echo "  (no build/storybook directory)" >&2
      exit 1
    fi
    cp "$_sb" $out/bin/

    # Storybook pages: installed under lib/ so nix-bundle-dir carries them
    # through. It closure-walks share/ (drops anything the binary doesn't
    # reference by absolute path), but treats lib/ as blanket-copied.
    # On macOS, mkMacOSApp then relocates lib/ subdirs into Resources/qt/qml/,
    # so main.cpp checks both layouts.
    # Copy the whole pages dir, not just *.qml — pages may ship image assets
    # they reference via Qt.resolvedUrl() (e.g. LogosArtworkPage's sample
    # icons). Globbing only *.qml silently produced a page whose Images could
    # never load, with no build-time signal.
    mkdir -p $out/lib/pages
    cp -r ${src}/storybook/pages/. $out/lib/pages/

    # Logos.Theme/.Controls/.Icons are STATIC-linked into LogosStorybook via
    # logos_design_system; nothing to copy for the design system itself.

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Browse and preview Logos Design System components";
    mainProgram = "LogosStorybook";
    platforms = platforms.unix ++ platforms.windows;
  };
}
