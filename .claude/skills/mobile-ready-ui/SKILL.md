---
name: mobile-ready-ui
description: Activate when writing or changing an app's QML screens with the Logos design system (import Logos.Controls / Logos.Layouts / Logos.Theme): new apps, new pages, layout fixes, "make it mobile", "responsive", "narrow window", "touch". Gives the width classes, the layout for each kind of page, the navigation and touch rules, and the renders at 390 / 700 / 1280 that prove a screen works.
---

# Mobile-ready UI for Logos apps

Every screen works at **390 px (a phone), 700 px (a tablet or a narrow window) and 1280 px (a
desktop)**, and is shown to. The rules and their reasons are in [docs/responsive.md](../../../docs/responsive.md);
this is the checklist. The storybook's **Reference app** (a wallet,
`storybook/pages/reference/`) has one section per kind of page below; copy from it.

## 1. Lay out by width class, measured on the component

| Class | Width | Page margin |
|---|---|---|
| `phone` | < 600 | 16 |
| `tablet` | 600 – 839 | 20 |
| `desktop` | ≥ 840 | 40 |

- `Theme.windowClass(width)` and `Theme.pageMargin(width)`, with the component's **own** `width`, never
  the window's or the screen's: an app docked in a narrow pane gets the phone layout.
- Never `Qt.platform.os` or the screen size for layout. The platform decides input only:
  `Theme.hasKeyboard` for keyboard hints (a narrowed desktop window still has Ctrl+K).
- Switch on a container's width, never on one your own content can widen.
- The `Logos.Layouts` already measure themselves. Most pages need no `windowClass` of their own.

## 2. The host frames the app; don't add a frame

An app in Basecamp is in a tab whose shell draws the chrome. Don't build a sidebar, a rail or a ☰
drawer: **no drawer on a phone**. Start the page with:

- `LogosPageHeader`: the title, subtitle and search, for a page.
- `LogosPageBar`: a 44 px bar with ‹, a title or picker, 🔍, actions and ⋯, for a page that goes deeper.
- `LogosSections`: for an app of several sections. On a phone the sections are a list the page goes back
  to.

Fill the root with `Theme.palette.background` (a bare view shows the host's clear colour) and
let the host size it. Don't set a `width`/`height` on the root.

## 3. Pick the layout for the page

| The page is… | Use | Reference app |
|---|---|---|
| several sections (a wallet, settings) | `LogosSections` + a `StackLayout` | the whole app |
| a dashboard | `LogosCardGrid` of `LogosStatCard`s (4 / 2×2 / 1, never 3+1); `LogosCardPair` for a main card and a side card | Overview |
| a table, its rows' details secondary | `LogosTable` with column `priority`, `phoneCards`, `rowMenu`, `rowsOpen`, in a `LogosSidePanel` | Activity |
| a list whose open item is the point (inbox) | `LogosListDetail` | |
| a form | `LogosFormLayout` + `LogosFormField`s (`narrow` pairs on a tablet), in a `LogosScrollView` | Send |
| settings | one column of `LogosListRow`s, at most `Theme.layouts.form.maximumWidth`: chevron = goes somewhere, `value` = current setting, `accessory: LogosSwitch` = on/off; destructive group last | Settings |
| a catalogue with filters | `LogosSidebarLayout`; while `!sideShown` the filters become pickers (filters aren't navigation) | |
| a header or row that may wrap | `LogosItemLayout`; actions that don't fit fold into `LogosOverflowRow`'s ⋯ | |
| loading / empty / error | `LogosStateView` | Activity's "No payments match" |

A page is usually one of these per region.

## 4. Navigation: one way back, a level at a time

- A section that goes a level deeper (a row's detail, a sub-page) exposes `canGoBack`, `backTitle` and
  `goBack()`. The app binds `LogosSections`' `canGoBack`, `backTitle` and `onBackRequested` to the open
  section's. The back row then names the level ("‹ Activity") and goes up one.
- A `LogosSidePanel` inside a section sets `backInHost: true`, so on a phone the section's back row
  closes it and the panel draws no ‹ of its own.
- Narrowing to phone width with a detail open keeps it open. Esc and the phone's Back key do what ‹
  does, and close the search first.
- Search never takes a row of its own on a phone. `LogosPageHeader`, `LogosPageBar` and
  `LogosSections` fold it into 🔍 for you. Elsewhere use `LogosSearchToggle`.

## 5. Touch

- `Theme.touch` (touch density, or a phone-wide view) makes every DS control reach
  `Theme.size.touchTarget` (44) by itself. Read sizes from `Theme.*`, never write them as numbers.
- Your own tappable item (a `MouseArea`, a custom row) needs a 44 × 44 hit area under `Theme.touch`.
  A small visual can sit inside a bigger area.
- Nothing needs hover or a double-click. A row's actions are a visible ⋯ (`LogosListRow.menu`,
  `LogosTable.rowMenu`). A context menu's touch path is a long press (`LogosMenu.contextFor`).
  A button's menu opens with `popupUnder(button)`, never at the cursor.
- Nothing lives only in a tooltip: show help under the field (`LogosFormField.help`) or as a line
  of the card or detail.
- Text you didn't write (names, notes, errors from a backend) gets `textFormat: Text.PlainText`;
  long text elides or wraps. Never scroll a page sideways.
- Dialogs and menus become sheets on a phone by themselves (`LogosDialog`, `LogosMenu`,
  `LogosComboBox`). Don't place them with fixed sizes.

## 6. Show it works (required before saying done)

**Design-system screens**:
- Run the storybook (`nix run .#storybook`). **Preview** opens the page at 390 and 700 and marks
  in red what reaches past the sides, and in orange the targets smaller than 44. **Density**
  switches to touch.
- `tests/tst_StorybookPhoneFit.qml` fails on any page with red at 390.
- A layout or control that adapts gets a scene in `tests/tst_PhoneFit.qml`.
- A page with states (a section, a detail, a form's errors) gets a test like
  `tests/tst_ReferenceApp.qml`: every state at 390, 700 (touch) and 1280, through `PhoneChecks.find`.

**An app's screens**:
- Load each view in the app's QML scene tests (a `qml-tests` app, as the Package Manager UI has).
  Set `Theme.viewWidth` to 390, 700 and 1280 as the host would, with touch density at 700, and
  `grabImage` each state.
- Or run it in Basecamp (`nix run .#ui-dev-portable`), resize the window, and screenshot it
  with the QML inspector (logos-qt-mcp).
- Give every tappable control an `objectName`. In `tests/*.mjs`, click by objectName, never by
  visible text, which can match another element (`nix run .#ui-tests`).

Done means:
1. No QML warnings: binding loops, TypeErrors, "is not installed".
2. Nothing past the sides at any of the three widths.
3. Nothing tappable under 44 at 390, or at 700 in touch density.
4. You **looked** at the renders (Read the PNGs), each width and each state, and each looks
   designed, not squeezed. Check font sizes against the design.
5. Desktop looks as it did before your change, unless the change was meant for desktop.

"Should work on mobile" is not done.

## 7. Don't

- Fix widths (`width: 560`, `Layout.preferredWidth: 800`). Use the layouts, `Layout.fillWidth`, or
  `Math.min(preferred, parent.width - 2 * Theme.pageMargin(parent.width))`.
- Add a ☰ drawer, a second back button, or a scaffold inside a hosted app.
- Fix one width at the cost of another. Re-check all three after every layout change.
- Copy a DS control to dodge a size problem. Use the DS's extension points (`cardDelegate`,
  `accessory`, `menu`, `body`), and report the gap to the design system.
