{
  description = "Logos Design System - Qt/QML design system (themes, colors, typography)";

  inputs = {
    # Use a specific nixpkgs version for Qt compatibility across projects
    # Projects using this design system should use the same nixpkgs or override it
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs }: rec {
        default = pkgs.stdenv.mkDerivation rec {
          pname = "logos-design-system";
          version = "1.0.0";

          # Exclude local build/ so Nix never sees a stale CMakeCache.txt
          src = builtins.path {
            path = ./.;
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

          cmakeFlags = [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
          ];

          preConfigure = ''
            export MACOSX_DEPLOYMENT_TARGET=12.0
          '';

          configurePhase = ''
            runHook preConfigure
            cmake -S . -B build $cmakeFlags
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            cmake --build build --target DesignSystemDemo || true
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            # Logos.Theme module (theme/ not DesignSystem)
            mkdir -p $out/lib/Logos/Theme
            cp ${src}/src/qml/theme/qmldir $out/lib/Logos/Theme/
            cp ${src}/src/qml/theme/*.qml $out/lib/Logos/Theme/
            cp -r ${src}/src/qml/theme/fonts $out/lib/Logos/Theme/

            # Logos.Controls module
            mkdir -p $out/lib/Logos/Controls
            cp ${src}/src/qml/controls/qmldir $out/lib/Logos/Controls/
            cp ${src}/src/qml/controls/*.qml $out/lib/Logos/Controls/

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Logos Design System - Qt/QML themes, colors, typography";
            platforms = platforms.unix;
          };
        };
      });

      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.cmake
            pkgs.ninja
          ];
          buildInputs = [
            pkgs.qt6.qtbase
            pkgs.qt6.qtdeclarative
          ];
          shellHook = ''
            echo "Logos Design System development shell"
            echo "Run: cmake -B build -GNinja && cmake --build build"
          '';
        };
      });
    };
}
