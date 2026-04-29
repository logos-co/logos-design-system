---
name: add-control
description: Activate when creating, modifying, or extending a QML control in this repo (src/qml/Logos/Controls/). Covers base-class choice (extend Qt Quick Control vs use plain Control), public API design (open for extension, closed for modification), alias patterns for testability, unit tests, and storybook pages.
---

# Add or modify a control in logos-design-system

A control here is a QML file under `src/qml/Logos/Controls/` exposed via `qmldir`. Every new control must ship with a unit test and a storybook page; every public property and signal is API and changing it is a breaking change.

## 1. Pick the base class

Two options. The decision is "what behavior do I get for free?":

| Use | When | Examples in repo |
|---|---|---|
| **Extend a Qt Quick Control** (`TabButton`, `ComboBox`, `Slider`, `CheckBox`, …) | The component is conceptually a Qt-native control — has the same interaction model, semantics, accessibility | `LogosTabButton extends TabButton`, `LogosTabBar extends TabBar` |
| **Use plain `Control`** | The component is a custom composition (icon + label + chrome) without a direct Qt counterpart | `LogosButton` (extends `Control`, owns its own `MouseArea`) |

If you find yourself writing your own `MouseArea` + hover tracking + accessibility hooks for something that's clearly a button, you should be extending `AbstractButton`/`Button`/`TabButton` instead.

## 2. Public API design

Order at the top of the file:

```qml
TabButton {                   // or Control / AbstractButton / etc.
    id: root

    // 1. Public properties (with explicit types and defaults)
    property color activeColor: Theme.palette.primary
    property color inactiveColor: Theme.palette.textTertiary
    property url   iconSource: ""

    // 2. Public signals (only if the base class doesn't already have them)
    // signal pageChanged(int newPage)

    // 3. Read-only inspection aliases (last — for tests / tooling only)
    readonly property alias iconItem: iconHolder
    readonly property alias labelItem: labelText

    // 4. Defaults for inherited properties
    implicitHeight: 40
    spacing: 6
    leftPadding: 8
    // ...

    // 5. Slot overrides (background, contentItem)
    background: Item {}
    contentItem: Item { ... }
}
```

Rules:

- **Type all properties** (`property color`, `property url`, `property int`, etc.). Untyped `property var` only when the value is genuinely heterogeneous.
- **Every configurable property has a default**. If a consumer doesn't set it, the control still renders correctly with theme tokens.
- **All defaults reference `Theme.*` tokens**. Never hardcode a color, spacing value, font size, or radius. If the token you need doesn't exist, add it to `DarkTheme.qml` first (and back it with a value in `ColorPalette.qml` / `Spacing.qml` / `Typography.qml`).
- **Public signals are part of the API contract**. Don't rely on inherited signals fired indirectly — declare your own if your control has a distinct event.

## 3. Open for extension, closed for modification

- Never expose a writable property whose semantics you can't promise to keep stable. Better to declare a new dedicated property than to leak an internal one.
- For every internal item that tests or external tooling need to inspect, add a **`readonly property alias <name>Item: <id>`**. Read-only — consumers can read state, never mutate. Examples: `indicatorItem` on `LogosTabBar`, `mouseAreaItem` on `LogosButton`, `placeholderItem` and `textInput` on `LogosTextField`.
- **`background:` and `contentItem:` are extension points**. A consumer can override either to re-skin without touching your code. Keep their defaults minimal so overrides don't fight inherited rules.
- **Don't assign to inherited properties from `Component.onCompleted`** unless absolutely necessary. Declarative bindings are predictable; imperative writes from completion handlers are not (we hit several Qt-version-specific issues in this repo where `Component.onCompleted` fired unreliably).

## 4. Known Qt 6 traps in this codebase

- **Group property sub-property assignments don't always re-fire bindings.** `icon.source: "..."` (where `icon` is `AbstractButton.icon`, a value-type group property) silently misses the change notification on some builds. If your control needs to react to icon presence, expose your own `property url iconSource: ""` and have the binding read that.
- **`Item.visible` returns *effective* visibility** (the AND of the ancestor chain). In offscreen test runs the chain may report invisible even when your local `visible: true` binding is correct. Don't make tests depend on `visible`.
- **`Component.onCompleted` and `Timer { running: true }` are not always reliable** on lazily-realized children (delegates inside `Container`/`ListView`). If you need first-paint init, prefer setting the property to its target default (`property bool ready: true`) and accepting a small first-paint cost over relying on a deferred handler.
- **Synthesized mouse events don't always reach inner `MouseArea`s through `Control`** (offscreen macOS QPA). For tests, click via the exposed `mouseAreaItem` alias and emit the signal directly: `btn.mouseAreaItem.clicked(null)`.

## 5. Unit tests

Every control gets `tests/tst_<Component>.qml`. The runner auto-discovers `tst_*.qml` — no registration step.

Skeleton:

```qml
import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: tc
    name: "LogosFoo"
    width: 400
    height: 200
    when: windowShown

    LogosFoo {
        id: foo
        // configure for the most common case
    }

    function init() {
        // reset state before each test
    }

    function test_<contract>() {
        // assert one thing
    }
}
```

Test design rules:

- **Test the contract, not the implementation.** Properties round-trip, signals emit, public state changes propagate to public state. Don't assert on private internals just because you can.
- **Prefer `tryCompare(obj, "prop", value)` over `tryVerify(function() { … })`**. The closure form is flakier across Qt versions.
- **Don't test `Item.visible`.** It's effective visibility (see §4) — fails in offscreen mode even when correct. Test position, size, property values, or signal emission instead.
- **For mouse interactions**, emit the signal directly on the inner `MouseArea` via the `mouseAreaItem` alias rather than `mouseClick(item)`. The latter is unreliable on offscreen QPA.
- **For images/icons in tests**, use the bundled `qrc:/test-icon.png` (a 1×1 RGBA PNG in `tests/test-resources.qrc`). Don't put random URLs that produce `Cannot open` warnings.
- **For animation/timing**, set the configurable duration to 0 (`animationDuration: 0`) and assert the final state with `tryCompare`. Don't try to verify intermediate frames — that's irreducibly flaky.

Run:

```bash
nix run .#tests          # full output
nix flake check          # CI form
```

## 6. Storybook page

Every control gets `storybook/pages/<Component>Page.qml`. The page is a regular `Rectangle` with `color: Theme.palette.background` that hosts:

- A title section
- A "States" group showing variants (default, disabled, hovered, etc.)
- A "Try it" group with live knobs (sliders, switches, text fields) that mutate the control's properties

Required:

```qml
Rectangle {
    property string figmaUrl: ""   // Figma link; empty hides the toolbar button
    color: Theme.palette.background
    // ...
}
```

Then register in `storybook/main.qml`'s `pages` array:

```qml
{ section: "Controls", title: "LogosFoo", file: "LogosFooPage.qml" }
```

Use existing pages (`LogosTabBarPage.qml`, `LogosButtonPage.qml`) as templates.

## 7. Tokens and conventions

Follow Qt's official **[QML Coding Conventions](https://doc.qt.io/qt-6/qml-codingconventions.html)** for ordering of property declarations, indentation, signal handler naming, grouped properties, and JS function style. The rules below are the project-specific additions on top.

- **Always reference `Theme.palette.*`, `Theme.spacing.*`, `Theme.typography.*`** — never hardcode hex/px values inside a control.
- **Use `LogosText`** for any text rendering (it carries the theme defaults). Reach for plain `Text` only if you're specifically overriding theme behavior.
- **camelCase** for properties, signals, ids, and functions (matches Qt's convention).
- **One control per file**; the file name matches the QML type name. `qmldir` registers `LogosFoo 1.0 LogosFoo.qml`.
- **Doc comment at the top** describing the public API and a short usage example. Mirror the format used in `LogosTabBar.qml`.
- **Object declaration order** (per Qt's convention): `id` first, then property declarations, then signal declarations, then JS functions, then object children, then signal handlers and states/transitions.

## 8. Pre-merge checklist

Before opening a PR for a new or modified control:

- [ ] No hardcoded colors, spacing, or font sizes — all values reference `Theme.*` tokens.
- [ ] Every configurable property is typed and has a sensible default.
- [ ] Internal items needed for tests/tooling are exposed as `readonly property alias <name>Item`.
- [ ] `background:` and `contentItem:` are overridable.
- [ ] `tests/tst_<Component>.qml` exists; `nix flake check` passes.
- [ ] `storybook/pages/<Component>Page.qml` exists and is registered in `main.qml`.
- [ ] `qmldir` updated with the new entry.
- [ ] `CMakeLists.txt` `CONTROLS_SOURCES` updated.
- [ ] Doc comment at the top of the QML file documents the public API and shows a minimal usage example.
- [ ] If the control's API differs from the Qt base class (e.g., custom `iconSource` instead of `icon.source`), explain *why* in the doc comment.
