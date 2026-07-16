{
  description = "Logos Design System - Qt/QML design system (themes, colors, typography)";

  inputs = {
    logos-nix.url = "github:logos-co/logos-nix";
    nixpkgs.follows = "logos-nix/nixpkgs";

    # Bundlers used to produce redistributable artifacts (AppImage / .app).
    # Same three tools basecamp uses (see logos-basecamp/flake.nix).
    # Every bundler's transitive nixpkgs / logos-nix / nix-bundle-dir follows
    # ours so the whole graph evaluates against one dependency set (avoids
    # `logos-nix_*` / `nixpkgs_*` clones in flake.lock).
    nix-bundle-dir = {
      url = "github:logos-co/nix-bundle-dir";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.logos-nix.follows = "logos-nix";
    };
    nix-bundle-appimage = {
      url = "github:logos-co/nix-bundle-appimage";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.logos-nix.follows = "logos-nix";
      inputs.nix-bundle-dir.follows = "nix-bundle-dir";
    };
    nix-bundle-macos-app = {
      url = "github:logos-co/nix-bundle-macos-app";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.logos-nix.follows = "logos-nix";
      inputs.nix-bundle-dir.follows = "nix-bundle-dir";
    };
  };

  outputs = { self, logos-nix, nixpkgs, nix-bundle-dir, nix-bundle-appimage, nix-bundle-macos-app }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs, system, ... }:
        let
          common = import ./nix/common.nix { inherit pkgs; };
          storybookDrv = import ./nix/storybook.nix { inherit pkgs common; };
          dirBundler = nix-bundle-dir.bundlers.${system}.qtApp;
        in
        rec {
          default = import ./nix/library.nix { inherit pkgs common; };
          storybook = storybookDrv;
          tests = import ./nix/tests.nix { inherit pkgs common; };

          # Self-contained tree: Qt libs + QML modules copied next to the
          # binary, RPATHs rewritten so nothing references /nix/store at
          # runtime. Base for the platform-specific bundles below.
          bin-bundle-dir = dirBundler storybookDrv;
        } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
          # Single-file .AppImage — click-to-run on any modern Linux with no
          # Nix installed. Consumed by CI (uploaded as build artifact).
          bin-appimage = nix-bundle-appimage.lib.${system}.mkAppImage {
            drv = storybookDrv;
            name = "logos-storybook";
            bundle = dirBundler storybookDrv;
            desktopFile = ./assets/logos-storybook.desktop;
            icon = ./assets/logos-storybook.png;
          };
        } // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
          # .app bundle — the macOS equivalent, produced only on Darwin.
          bin-macos-app = nix-bundle-macos-app.lib.${system}.mkMacOSApp {
            drv = storybookDrv;
            name = "LogosStorybook";
            bundle = dirBundler storybookDrv;
            icon = ./assets/macos/logos-storybook.icns;
            infoPlist = ./assets/macos/Info.plist.in;
            entitlements = ./assets/macos/LogosStorybook.entitlements;
          };
        });

      apps = forAllSystems ({ system, ... }: rec {
        storybook = {
          type = "app";
          program = "${self.packages.${system}.storybook}/bin/LogosStorybook";
        };
        tests = {
          type = "app";
          program = "${self.packages.${system}.tests}/bin/LogosDesignSystemTests";
        };
        default = storybook;
      });

      checks = forAllSystems ({ system, ... }: {
        tests = self.packages.${system}.tests;
      });

      devShells = forAllSystems ({ pkgs, ... }: {
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
