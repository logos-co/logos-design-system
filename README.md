# Logos Design System

The Qt/QML design system for Logos applications. QML modules — `Logos.Theme` for design tokens, `Logos.Controls` for themed components and `Logos.Layouts` for the bars and panes a page is built from — plus a storybook for browsing them and a unit test suite.

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
| `Theme.qml` | Singleton: `Theme.palette`, `Theme.spacing`, `Theme.typography`, `Theme.size`, `Theme.controls`, `Theme.layouts`, `Theme.density` / `Theme.touch`, width classes, theme switching |
| `ColorPalette.qml` | Raw color values (gray, orange, red, green, …) — single source of truth |
| `DarkTheme.qml` | Semantic palette mapped from `ColorPalette`: `text`, `background`, `primary`, `success`, `border`, `surface`, `surfaceRaised`, `borderHairline`, etc. |
| `Spacing.qml` | Spacing scale (`tiny:4` … `xxlarge:40`) and corner radii (`radiusSmall:4` … `radiusPill:999`) |
| `Typography.qml` | Public Sans font loaders, weights, type sizes |
| `Sizes.qml` | Shared size scale: control heights (`controlXSmall:24` … `controlXLarge:44`), icon sizes, `borderWidth`, `focusWidth`, `touchTarget` |
| `ControlTokens.qml` | Each control's own dimensions (`Theme.controls.button.height`, `Theme.controls.toggle.trackWidth`, …), defaulting to the shared scale where a value is shared; density scales the tappable ones |
| `LayoutTokens.qml` | The `Logos.Layouts` types' dimensions (`Theme.layouts.pageBar.height`, `Theme.layouts.listDetail.desktopListWidth`, …) |
| `ThemeStore`, `ThemeManager` (C++) | Installed `theme.json` files that recolour `Theme.palette`, from a directory the host chooses, and the density; only the host installs and switches. `ThemeManager::followViewWidth()` tells each view's engine its width. `ThemeRegistry` is QML's read-only view. See [docs/themes.md](docs/themes.md) |

### `Logos.Controls` — themed components

Components are split into two groups. **Designed** controls have their final styling applied. **Placeholders** are themed minimally with current tokens (correct fonts, colors, radii) and ship with full tests + a storybook page, but their visuals will be replaced when the Figma spec for that control lands.

**Designed**: `LogosButton`, `LogosCheckbox`, `LogosComboBox`, `LogosIconButton`, `LogosPaginator`, `LogosSearchBar`, `LogosTabBar`, `LogosTabButton`, `LogosTable` + `LogosTableColumn`, `LogosText`, `LogosTextField`.

**Placeholder**: `LogosButtonRow`, `LogosDialog`, `LogosFrame`, `LogosGroupBox`, `LogosListRow`, `LogosMenu` + `LogosMenuItem`, `LogosProgressBar`, `LogosRadioButton`, `LogosScrollBar`, `LogosSearchToggle`, `LogosSlider`, `LogosSpinBox`, `LogosSpinner`, `LogosStateView`, `LogosSwitch`, `LogosTextArea`, `LogosToolBar` + `LogosToolButton`.

Text is plain by default: `LogosText`, and every control that draws its text with it, shows markup as written rather than rendering it, and so does `LogosToolTip`. Opt in with `textFormat: Text.StyledText` (bold, links, line breaks) where the text is your own; never for names, messages or anything else from outside the app.

Open the storybook to see public API, props, and live examples for each. Internal items exposed via `*Item` aliases (e.g. `indicatorItem`, `labelItem`) are for inspection by tests and tooling — read-only handles.

### `Logos.Layouts` — page pieces

The bars and panes a page is built from; controls go inside them. Each arranges itself by its own width (`Theme.windowClass`), so a page laid out with them works from phone to desktop:

- `LogosPageBar` — the page's top row: title, ‹ back, search, actions and a ⋯ menu. At phone width search folds into an icon.
- `LogosListDetail` — a list and the detail of its open item: side by side from tablet width; at phone width the detail replaces the list. The detail's actions (`detailActions`) are a row across its top, or at phone width an equal-width bar pinned to the bottom.
- `LogosCardGrid` — cards or tiles in as many equal columns as fit, from the width the grid gets; content at most 1200 px, centred. Balanced, it never leaves one card alone on the last row: four stat cards are 4, 2 × 2 or 1.
- `LogosFormLayout` + `LogosFormField` — a form at most 720 px wide, centred: labels beside the controls on desktop, above them narrower, narrow fields paired on a tablet, one field per row and stacked buttons on a phone. Help and errors are text under the control.
- `LogosCardPair` — a wide card and its side card, side by side (2 : 1) while both stay usable, otherwise stacked.
- `LogosWizard` — a task in steps, as the apps' onboarding does it: an optional welcome screen, a title, a rail of the steps across the top, and Back on the left with a main button that names what it does; a hint beside it says why it can't be pressed yet. On a phone only the current step is named and the buttons stack, the main one last. Esc and the phone's Back key go back.
- `LogosWelcome` — an onboarding's first screen: a backdrop, a title and the ways in, centred or aligned left, with a slot over the title and four corners for what the app adds (brand, close, version, other ways in); on a phone the bottom corners stack. Its `background` can be replaced. A wizard's `welcome`.
- `LogosSections` — an app with several sections: a list of them beside the current one from tablet width; on a phone the app opens on its current section and ‹ goes back to the list. There is no ☰ drawer.

All are placeholders for now, under **Layouts (not designed)** in the storybook. [docs/responsive.md](docs/responsive.md) shows how a page is put together from them.

#### Designed vs placeholder

Each storybook page declares `property bool designed` — `true` (the default) for final controls, `false` for placeholders. Placeholders are listed under the **Controls (not designed)** sidebar section in the storybook so reviewers and consumers can see at a glance what's finalised vs. pending.

When a placeholder graduates to designed:

1. Replace the visuals in `src/qml/Logos/Controls/Logos<X>.qml` with the final spec.
2. In `storybook/pages/Logos<X>Page.qml`, flip `property bool designed: false` → `true` (or remove the line, since `true` is the default).
3. In `storybook/main.qml`, move the entry from the `"Controls (not designed)"` section to the `"Controls"` section so it appears at the top.
4. Add or update tests in `tests/tst_Logos<X>.qml` for any new design-specific behaviour.
5. If a Figma URL exists, set `property string figmaUrl: "..."` on the page root so the storybook header surfaces an "Open in Figma" button.

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
│   ├── Controls/              Logos.Controls module
│   └── Layouts/               Logos.Layouts module
├── storybook/                 catalog browser host app + per-page QML
│   ├── main.cpp + main.qml    host with sidebar, dark/light toggle, hot-reload, phone/tablet preview
│   ├── PhoneChecks.js         what wouldn't work on a phone (preview marks, tst_PhoneFit)
│   └── pages/                 one .qml per token group / control
├── tests/                     QtQuickTest unit tests
│   ├── main.cpp               quick_test_main_with_setup wiring
│   ├── tst_*.qml              one file per component (LogosTabBar, LogosButton, …)
│   ├── test-icon.png          1×1 RGBA PNG bundled via test-resources.qrc
│   └── CMakeLists.txt
├── docs/                      themes.md (theme files), responsive.md (phone to desktop)
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
import Logos.Layouts   // page bars and panes, if the page uses them

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
nix flake check              # .#tests, plus an offscreen launch of what `nix run` runs
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

**Preview** opens the page again in a window of a phone's size (390 px) or a tablet's (700 px). That window has its own overlay, as an app's view does, so menus and dialogs place themselves there as they would on the device. While it is open, `Theme.viewWidth` is its width, so on a phone every tappable part is touch-sized, in the main window too. Every second the preview marks in red what reaches past its sides and, where targets are touch-sized, in orange what is too small to tap; hover a mark for what it is. `tests/tst_PhoneFit.qml` runs the same checks (`storybook/PhoneChecks.js`) on the layouts and controls at a phone's width, and `tests/tst_StorybookPhoneFit.qml` on every storybook page. **Density** switches compact, comfortable and touch.

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
- Synthesized mouse and touch events reach nothing in an invisible `TestCase`, which is Qt's default. For real input give the TestCase `visible: true` and `waitForRendering(item)` after creating an item; otherwise emit `mouseAreaItem.clicked(null)` directly.

## Tokens at a glance

`Theme.palette.*` semantic colors:
- **Surfaces & backgrounds**: `background`, `backgroundSecondary`, `backgroundElevated`, `surface`, `surfaceRaised`, `backgroundButton`, `backgroundInset`
- **Text**: `text`, `textSecondary`, `textTertiary`, `textPlaceholder`, `textMuted`
- **Borders**: `border`, `borderSubtle`, `borderHairline`, `borderInteractive`, `borderDark`
- **Primary / accent**: `primary`, `primaryHover`, `primaryPressed`, `primarySoft`, `primaryForeground` (text and icons on `primary`)
- **Status**: `success`, `error`, `warning`, `info`, `notification`
- **Interactive states**: `hover`, `pressed`, `disabled`, `focus`
- **Overlays**: `glassOverlay`, `glassStrong`, `overlayDark`, `overlayLight`, `overlayOrange`

`Theme.spacing.*`: `tiny:4`, `small:8`, `medium:12`, `large:16`, `xlarge:20`, `xxlarge:40`, plus `radiusSmall:4`, `radiusMedium:6`, `radiusLarge:8`, `radiusXlarge:16`, `radiusPill:999`.

`Theme.size.*`: control heights `controlXSmall:24`, `controlSmall:32`, `controlMedium:36`, `controlLarge:40`, `controlXLarge:44`; icons `iconXSmall:12`, `iconSmall:16`, `iconMedium:20`; strokes `borderWidth:1`, `focusWidth:2`; `touchTarget:44`, the smallest area a finger can reliably tap.

`Theme.density` is `compact`, `comfortable` or `touch`. The host picks it with `ThemeManager.setDensity()`, and it is saved with the theme choice; the default is comfortable (the desktop's sizes), or touch on Android and iOS. Density scales the tappable controls' sizes in `Theme.controls` (×0.85, ×1, ×1.2). At touch density (`Theme.touch`):
- every tappable part is at least `Theme.size.touchTarget` each way; a small visual (checkbox box, info ring, flat icon) keeps its size inside a transparent margin;
- a long-press on a `LogosToolTip`'s parent opens the tip, and on a Logos control that long-press is not also a click; on a control without a tip, a long-press is still a click;
- links are always underlined, a tap holds a toast, and a tap anywhere in a table's checkbox cell toggles the row.

Tooltips stay extras: never put something only in a tooltip, since touch users have to know to long-press.

[docs/responsive.md](docs/responsive.md) is the guide to pages that work on a phone, a tablet and a desktop. Layout follows the width of an app's own area, not the screen. `Theme.windowClass(width)` is `phone` (< 600), `tablet` (< 840) or `desktop`, and `Theme.pageMargin(width)` the page's side margin (16 / 20 / 40). The host keeps each view's engine told the view's width with `ThemeManager::followViewWidth(root)`; `Theme.viewClass` is then that view's class, and desktop until the host sets it. A phone-width view gets touch-size targets at any density (`Theme.touch`), without the touch density's larger sizes. Two widths, on purpose: a component arranges itself by its own width, so a wizard in a narrow desktop pane stacks its buttons; type sizes and touch targets follow the whole view (`Theme.viewClass`), so text stays one scale across a view.

On a phone, what covers the window's edges: `Theme.safeAreaTop` / `safeAreaBottom` (the notch and the home indicator; `followViewWidth` keeps them from Qt 6.9) and `Theme.keyboardHeight` (the on-screen keyboard). `Theme.topInset(item)` and `Theme.bottomInset(item)` say how much of an item they cover. Sheets, full-page dialogs, the wizard and the list → detail action bar stay clear of them, and in a dialog, a wizard or a form the field with focus scrolls into view above the keyboard.

A `LogosDialog` left to place itself is centred at its `preferredWidth`, never wider than its parent less the page margins. In a phone-wide parent it is a bottom sheet, or with `fullPage` it fills the parent, for long content such as a form; either way its actions stack full width, the main ones last. Put your own content in `body`: it scrolls when the dialog is shorter than it, while the title and actions stay. A dialog that sets `anchors.centerIn` or `width` keeps that placement off a phone; on one it is still a sheet or a page, across the window it is centred in.

A `LogosMenu` in a phone-wide window opens as a sheet across the bottom, however it is opened: the page dims, the items span the width, and a tap on the page or a drag down on the handle closes it. `contextFor` makes a menu an item's context menu: a right-click opens it there and a long press, the touch path, at the item. A `LogosListRow` with a `menu` shows a ⋯ for it, which a long press on the row opens too; `caption` gives it a third line. A dialog decides by its parent's width, a menu by its window's, since a menu's parent is the button that opens it.

A `LogosPaginator` short of room drops its page-size selector first, then its info text, and then condenses its page numbers to ‹ 4 / 10 ›, keeping « » while they fit. Where all of it fits it is as before.

`Theme.controls.<control>.*`: each control's sizes, for example `button.height`, `button.compactHeight`, `field.paddingX`, `checkbox.indicatorSize`, `table.rowHeight`. Controls read their sizes only from here and from `Theme.size`, never from literals; `tests/check-size-literals.sh` enforces it. The full list is in `src/qml/Logos/Theme/ControlTokens.qml`.

`Theme.layouts.<layout>.*`: the same for `Logos.Layouts`, for example `pageBar.height`, `listDetail.tabletListWidth`, `sections.listWidth` (`LayoutTokens.qml`). Density doesn't scale them; it scales the controls inside.

`Theme.typography.*`: `weightRegular:400`, `weightMedium:500`, `weightBold:700`, sizes `badgeText:8`, `secondaryText:12`, `primaryText:14`, `subtitleText:16`, `panelTitleText:24`, `titleText:30`, `pageTitleText:36`, `mainTitleText:256`. In a phone-wide view the titles step down (`panelTitleText:20`, `titleText:24`, `pageTitleText:28`, `mainTitleText:96`); body sizes stay. Where targets are touch-sized, `badgeText` is 10.

The storybook's **Colors / Spacing / Typography** pages show the full set with names — open it whenever you need to find a token.

## Requirements

- Qt 6.x (qtbase + qtdeclarative)
- CMake 3.16+
- C++17

## Contributing

1. **Add colors to `ColorPalette.qml` first**, then map to a semantic name in `DarkTheme.qml` and add it to the list in `ThemeStore.cpp` so theme files can set it. The semantic name is what consumers should reference (`Theme.palette.surfaceRaised`, not `Theme.colors.gray360`).
2. **For new controls**: extend the right Qt Quick Controls base (`Control`, `TabButton`, etc.), expose only what consumers actually need, and add a `readonly property alias <name>Item: <id>` for any internal item that tests / tooling need to inspect.
3. **Decide designed vs placeholder.** If the Figma spec is final, ship as a designed control: register under `"Controls"` in `storybook/main.qml` and either omit `designed` on the page (defaults to true) or set it to `true` explicitly. If the spec is pending, ship as a placeholder: theme it minimally with `Theme.palette.*` / `Theme.spacing.*`, register under `"Controls (not designed)"`, and set `property bool designed: false` on the page. Both kinds get the same testing + storybook treatment so promotions are mechanical.
4. **Add a storybook page** for any new control (`storybook/pages/Logos<X>Page.qml`) and a unit test (`tests/tst_Logos<X>.qml`).
5. **Promoting a placeholder to designed** — see the *Designed vs placeholder* section above for the four-step flip.
6. Run `nix flake check` before pushing — CI runs the same.
