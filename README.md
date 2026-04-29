# Logos Design System

The Qt/QML design system for Logos applications. Two QML modules — `Logos.Theme` for design tokens and `Logos.Controls` for themed components — plus a storybook for browsing them and a unit test suite.

```
nix build                    # the QML library (what consumers depend on)
nix run                      # browse components + token catalog (alias of .#storybook)
nix run .#tests              # run the QML unit tests
nix flake check              # CI: build + test
```

## What's inside

### `Logos.Theme` — design tokens

| File | Provides |
|---|---|
| `Theme.qml` | Singleton: `Theme.palette`, `Theme.spacing`, `Theme.typography`, theme switching |
| `ColorPalette.qml` | Raw color values (gray, orange, red, green, …) — single source of truth |
| `DarkTheme.qml` | Semantic palette mapped from `ColorPalette`: `text`, `background`, `primary`, `success`, `border`, `surface`, `surfaceRaised`, `borderHairline`, etc. |
| `Spacing.qml` | Spacing scale (`tiny:4` … `xxlarge:40`) and corner radii (`radiusSmall:4` … `radiusPill:999`) |
| `Typography.qml` | Public Sans font loaders, weights, type sizes |

### `Logos.Controls` — themed components

| Component | Public API (in addition to inherited Qt Controls API) |
|---|---|
| `LogosText` | Themed `Text` (default Public Sans + `Theme.palette.text`) |
| `LogosButton` | `text`, `clicked()`, exposed `mouseAreaItem` |
| `LogosTextField` | `text`, `placeholderText`, `placeholderTextColor`, `echoMode`; aliases `textInput`, `placeholderItem` |
| `LogosTabBar` | `indicatorColor`, `indicatorHeight`, `animationDuration`; sliding underline below the active tab |
| `LogosTabButton` | `iconSource: url`, `activeColor`, `inactiveColor`; aliases `iconItem`, `labelItem`. Use inside `LogosTabBar`. |

Internal items exposed via `*Item` aliases (e.g. `indicatorItem`, `labelItem`) are for inspection by tests and tooling — treat them as read-only handles.

## Repo layout

```
.
├── flake.nix                  thin orchestrator — inputs, outputs, devShell
├── nix/
│   ├── common.nix             shared src + buildInputs + cmake flags
│   ├── library.nix            packages.default       (the QML library)
│   ├── storybook.nix          packages.storybook     (host app)
│   └── tests.nix              packages.tests         (test runner)
├── src/qml/Logos/
│   ├── Theme/                 Logos.Theme module
│   └── Controls/              Logos.Controls module
├── storybook/                 catalog browser host app + per-page QML
│   ├── main.cpp + main.qml    host with sidebar, dark/light toggle, hot-reload
│   └── pages/                 one .qml per token group / control
├── tests/                     QtQuickTest unit tests
│   ├── main.cpp               quick_test_main_with_setup wiring
│   ├── tst_*.qml              one file per component (LogosTabBar, LogosButton, …)
│   ├── test-icon.png          1×1 RGBA PNG bundled via test-resources.qrc
│   └── CMakeLists.txt
├── CMakeLists.txt             top-level: opt-in storybook + tests via flags
└── .github/workflows/ci.yml   build + tests + storybook smoke
```

## Build & run

### Using the design system from a consumer (recommended)

The QML library is published as `packages.${system}.default`. Each consumer's flake declares it as an input and copies the modules into its own `$out/lib/Logos/`:

```nix
# consumer flake.nix
inputs.logos-design-system.url = "github:logos-co/logos-design-system";
inputs.logos-design-system.inputs.nixpkgs.follows = "logos-cpp-sdk/nixpkgs";

# consumer nix/app.nix installPhase:
cp -r "${logos-design-system.packages.${system}.default}/lib/Logos" "$out/lib/"
```

Then in QML:
```qml
import Logos.Theme
import Logos.Controls

Rectangle {
    color: Theme.palette.background
    LogosButton {
        text: "Hello"
        onClicked: console.log("clicked")
    }
}
```

For dev-time override (work on the design system + your app in parallel), set `LOGOS_DESIGN_SYSTEM_ROOT` to the design-system's `result/` so your app picks up the live source. See `logos-basecamp/run-dev.sh` for the canonical pattern.

### Building locally

```bash
nix build                    # QML library only — drops .qml files into result/lib/Logos/
nix build .#storybook        # storybook host app
nix build .#tests            # build + run unit tests via doCheck
nix flake check              # same as `nix build .#tests`
```

For a non-nix CMake build:
```bash
cmake -B build -GNinja -DLOGOS_DS_BUILD_STORYBOOK=ON -DLOGOS_DS_BUILD_TESTS=ON
cmake --build build
(cd build && ctest --output-on-failure)
./build/storybook/LogosStorybook
```

The CMake options are off by default — the default `nix build` ships only the QML files.

## Storybook

Interactive catalog of every token and control. Use it to:
- Browse all `Theme.palette.*` colors (with names, hex values, swatches)
- See the `Theme.spacing.*` scale visualized as bars + radii
- Sample every typography size and weight
- Poke each control's states with live knobs (text input, toggles, sliders)
- Open the matching Figma frame for any page (when its `figmaUrl` is set)

```bash
nix run                      # bare run — apps.default points at the storybook
nix run .#storybook          # explicit form (same thing)
nix build .#storybook && ./result/bin/LogosStorybook   # build then launch manually
```

### Hot reload during development

The storybook host app watches the `pages/` directory and the design-system QML source tree. Edits to any `.qml` file land within ~150 ms — no rebuild needed.

The header has manual **Reload** and **Light/Dark** buttons. The "Open in Figma" button appears on pages where the page's `figmaUrl` property is set.

### Adding a new page

Create `storybook/pages/<NewControl>Page.qml`, register it in the `pages` array in `storybook/main.qml`, run the storybook. Optionally set `figmaUrl: "https://figma.com/file/.../?node-id=..."` on the page root so the toolbar's Figma link appears.

## Tests

QtQuickTest unit tests, one file per component. Run via `nix flake check` in CI, or directly while iterating:

```bash
nix run .#tests                      # full output, all PASS/FAIL lines
nix flake check                      # CI form — silent on success
```

For verbose runs:
```bash
./result/bin/LogosDesignSystemTests           # default output
./result/bin/LogosDesignSystemTests -v2        # extra signal/timing info
./result/bin/LogosDesignSystemTests -functions # list every test
./result/bin/LogosDesignSystemTests -xunitxml -o tests.xml    # JUnit XML for CI
```

### Adding a new test

1. Add `tests/tst_<Component>.qml` with a `TestCase { … }` block. Use `id: tc`, set `width`/`height`, and `when: windowShown`.
2. The runner picks it up automatically — `tests/main.cpp` adds the design-system QML import path; `tst_*.qml` files in `tests/` are auto-discovered.
3. For new components, expose internal items via `readonly property alias <name>Item: <id>` so tests can assert on them without going through `findChild`.

### Notes on test design

- Prefer `tryCompare(obj, "prop", value)` over `tryVerify(function() { … })`. The closure-based form has had reliability issues across Qt versions.
- `Item.visible` returns *effective* (ancestor-chain) visibility — unreliable in offscreen test runs. Test what you actually care about (existence, position, size, property round-trips) instead of asserting on `visible`.
- For mouse interactions, emit `mouseAreaItem.clicked(null)` directly. Synthesized `mouseClick` events do not always reach inner `MouseArea`s through `Control` on offscreen QPA.

## Tokens at a glance

`Theme.palette.*` semantic colors:
- **Surfaces & backgrounds**: `background`, `backgroundSecondary`, `backgroundElevated`, `surface`, `surfaceRaised`, `backgroundButton`, `backgroundInset`
- **Text**: `text`, `textSecondary`, `textTertiary`, `textPlaceholder`, `textMuted`
- **Borders**: `border`, `borderSubtle`, `borderHairline`, `borderInteractive`, `borderDark`
- **Primary / accent**: `primary`, `primaryHover`, `primaryPressed`, `primarySoft`
- **Status**: `success`, `error`, `warning`, `info`, `notification`
- **Interactive states**: `hover`, `pressed`, `disabled`, `focus`
- **Overlays**: `glassOverlay`, `glassStrong`, `overlayDark`, `overlayLight`, `overlayOrange`

`Theme.spacing.*`: `tiny:4`, `small:8`, `medium:12`, `large:16`, `xlarge:20`, `xxlarge:40`, plus `radiusSmall:4`, `radiusMedium:6`, `radiusLarge:8`, `radiusXlarge:16`, `radiusPill:999`.

`Theme.typography.*`: `weightRegular:400`, `weightMedium:500`, `weightBold:700`, sizes `secondaryText:12`, `primaryText:14`, `titleText:30`, `mainTitleText:256`.

The storybook's **Colors / Spacing / Typography** pages show the full set with names — open it whenever you need to find a token.

## Requirements

- Qt 6.x (qtbase + qtdeclarative)
- CMake 3.16+
- C++17

## Contributing

1. **Add colors to `ColorPalette.qml` first**, then map to a semantic name in `DarkTheme.qml`. The semantic name is what consumers should reference (`Theme.palette.surfaceRaised`, not `Theme.colors.gray360`).
2. **For new controls**: extend the right Qt Quick Controls base (`Control`, `TabButton`, etc.), expose only what consumers actually need, and add a `readonly property alias <name>Item: <id>` for any internal item that tests / tooling need to inspect.
3. **Add a storybook page** for any new control (`storybook/pages/Logos<X>Page.qml`) and a unit test (`tests/tst_Logos<X>.qml`).
4. Run `nix flake check` before pushing — CI runs the same.
