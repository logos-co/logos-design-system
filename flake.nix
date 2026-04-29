{
  description = "Logos Design System - Qt/QML design system (themes, colors, typography)";

  inputs = {
    logos-nix.url = "github:logos-co/logos-nix";
    nixpkgs.follows = "logos-nix/nixpkgs";
  };

  outputs = { self, logos-nix, nixpkgs }:
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

          # The default package ships QML files only; there is nothing to
          # compile. Skip the build phase entirely.
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
        };

        storybook = pkgs.stdenv.mkDerivation rec {
          pname = "logos-storybook";
          version = "1.0.0";

          src = builtins.path {
            path = ./.;
            name = "logos-storybook-src";
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
            "-DLOGOS_DS_BUILD_STORYBOOK=ON"
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
            cmake --build build --target LogosStorybook
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            # Binary
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
        };
      });

      apps = forAllSystems ({ pkgs }: rec {
        storybook = {
          type = "app";
          program = "${self.packages.${pkgs.system}.storybook}/bin/LogosStorybook";
        };
        default = storybook;
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
