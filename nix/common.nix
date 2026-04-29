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
    pkgs.qt6.wrapQtAppsHook
  ];

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
  ];
}
