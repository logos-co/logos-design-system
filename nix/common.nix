{ pkgs }:

# Shared build configuration consumed by ./library.nix, ./storybook.nix and
# ./tests.nix. Centralizing here keeps each derivation focused on what makes
# it different (its build/install rules), not the Qt + cmake boilerplate.
{
  src = builtins.path {
    path = ./..;
    name = "logos-design-system-src";
    filter = path: type:
      type != "directory" || baseNameOf path != "build";
  };

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.ninja
  ]
  # wrapQtAppsHook FAILS TO EVALUATE for a mingw host, and would be useless
  # anyway: wrap-qt-apps-hook.sh does `isELF || isMachO || continue`, so a PE is
  # never wrapped. Gating it off is only half the fix -- qtbase's own setup hook
  # hard-errors in qtPreHook with "depends on qtbase, but no wrapping behavior
  # was specified" unless `dontWrapQtApps = true` is also set on each
  # derivation. Both halves are mandatory.
  ++ pkgs.lib.optional (!pkgs.stdenv.hostPlatform.isWindows) pkgs.qt6.wrapQtAppsHook;

  buildInputs = [
    pkgs.qt6.qtbase
    pkgs.qt6.qtdeclarative
  ];

  preConfigure = ''
    export MACOSX_DEPLOYMENT_TARGET=12.0
  '';

  baseCmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=Release"
  ]
  # Qt splits its host TOOLS (moc, rcc, qmltyperegistrar, qsb) into separate
  # packages that must run on the BUILD machine; -DQT_HOST_PATH=<qtbase> cannot
  # reach them. The overlay hoists the required Qt6*Tools_DIR flags into this
  # attribute, which is empty on native builds. The symptom when it is missing
  # is misleading -- CMake names the target-side package (e.g. Qt6QmlTools),
  # which is present; it is the host-tools package that is absent.
  ++ (pkgs.logosQtCrossCmakeFlags or [ ]);
}
