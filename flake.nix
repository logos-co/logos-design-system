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
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs, ... }:
        let
          common = import ./nix/common.nix { inherit pkgs; };
        in
        rec {
          default = import ./nix/library.nix { inherit pkgs common; };
          storybook = import ./nix/storybook.nix { inherit pkgs common; };
          tests = import ./nix/tests.nix { inherit pkgs common; };
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
