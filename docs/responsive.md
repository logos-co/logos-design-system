# Responsive layouts

How to build a page that works on a phone, a tablet and a desktop with the
design system. The short version: build the page from `Logos.Layouts`, put
`Logos.Controls` inside, never fix a width, and check it in the storybook's
phone preview.

## Width classes

Layout follows the width of the app's own area, not the screen's. An app
docked in a narrow pane on a desktop gets the phone layout, and an app on a
large tablet the desktop one.

| Class | Width | Page margin |
|---|---|---|
| `phone` | < 600 | 16 |
| `tablet` | 600 – 839 | 20 |
| `desktop` | ≥ 840 | 40 |

- `Theme.windowClass(width)` gives the class of a width,
  `Theme.pageMargin(width)` the side margin that goes with it, and
  `Theme.tileWidth(width)` a tile's narrowest cell in a catalogue that wide
  (104, 140, 180: three across a phone).
- **A component goes by its own width.** Each layout and control measures
  itself: a form in a 500 px pane of a desktop window lays out as on a phone.
  Pass a component's own `width` to `Theme.windowClass`, not the window's.
- **A component inside a narrow column goes by its container.** A button row
  inside a 400 px form column is narrow at every size; set
  `stackOnPhone: Theme.windowClass(form.width) === "phone"` so it stacks only
  when the whole form is phone-wide.
- `Theme.viewClass` is the class of the whole view, which the host keeps up to
  date with `ThemeManager::followViewWidth(root)`, one call per view. It is
  `desktop` until the host sets it. Use it for what belongs to the whole view
  (type sizes, touch targets), not for layout.

## Touch

`Theme.touch` is true at touch density and in a phone-wide view. Then every
tappable part is at least `Theme.size.touchTarget` (44) each way: buttons,
fields, rows, checkboxes (the box keeps its size inside a transparent
margin), the page bar's ‹, a table's checkbox cells. A long press opens a
tooltip, so never put something only in a tooltip.

Read sizes from `Theme.controls.*` and `Theme.size.*`, never write them as
numbers: that is how a control gets its touch size.

## Type

In a phone-wide view the title sizes step down; body text stays.

| Token | Desktop | Phone |
|---|---|---|
| `displayText` | 40 | 28 |
| `pageTitleText` | 36 | 28 |
| `titleText` | 30 | 24 |
| `panelTitleText` | 24 | 20 |
| `mainTitleText` | 256 | 96 |
| `badgeText` | 8 | 10 (wherever targets are touch-sized) |

## The page skeleton: `Logos.Layouts`

| Layout | Phone | Tablet | Desktop |
|---|---|---|---|
| `LogosPageBar` | 44 px; search folds into an icon and takes the whole bar when open; ⋯ for the rest | 56 px, search field shown | same |
| `LogosListDetail` | the list, or the open item's detail in its place; ‹ goes back | list (320) beside the detail | list (360) beside the detail |
| `LogosSidePanel` | the content, or the open panel in its place; ‹ goes back | the panel (320) beside the content, which narrows for it; ✕ closes it | same |
| `LogosSections` | the list of sections is the page, a card of rows; a tap opens the section under a ‹ Title row, which names a level deeper and goes up one; a section's search is a 🔍 at that row's end. **No ☰ drawer** | title, subtitle and a section's search over the list (168) beside the section's card; a level deeper puts the ‹ row at the top of the card | the same, list 200 |
| `LogosPageHeader` | title, then its subtitle (or a `shortTitle`, and no subtitle with `subtitleOnPhone: false`); the search a 🔍 at the end of the title's line, open across it | title and subtitle, the search beside them (`searchWidth`, giving way to the title) | same |
| `LogosSidebarLayout` | the content alone (`sideShown` false): the app shows what the sidebar holds another way, e.g. pickers | the sidebar (200) beside the content while the content keeps `minimumContentWidth`; by what fits, not the class | same |
| `LogosOverflowRow` | a row while its items fit, else ⋯ opening the app's menu; by what fits, not the class | same | same |
| `LogosItemLayout` | one line of an item while it fits; else meta goes under the content, to the item's end, wrapping, and leading and trailing stay at the ends, at the top | by what fits, not the class | same |
| `LogosCardGrid` | as many equal columns as fit at `minimumCellWidth` (for tiles, `Theme.tileWidth(width)`), from its own width; never one card alone on the last row (`balanced`); content at most 1200, centred | same | same |
| `LogosCardPair` | main card above its side card | side by side 2 : 1 once both are usable (400 and 220) | same |
| `LogosFormLayout` | one field per row, labels above, buttons stacked full width, main last | narrow fields in pairs | labels beside the controls, at most 720 wide, centred |
| `LogosWizard` | the rail names only the current step; buttons stacked full width, the main one last, its hint above them | title, a rail of the steps across the top, Back on the left and the main button on the right with its hint beside it | same |

A typical app page:

```qml
ColumnLayout {
    anchors.fill: parent
    spacing: 0

    LogosPageBar {
        Layout.fillWidth: true
        title: inbox.showingDetail ? current.subject : qsTr("Inbox")
        canGoBack: inbox.showingDetail
        searchEnabled: !inbox.showingDetail
        onBackRequested: inbox.detailOpen = false
        menu: LogosMenu { LogosMenuItem { text: qsTr("Mark all read") } }
    }

    LogosListDetail {
        id: inbox
        Layout.fillWidth: true
        Layout.fillHeight: true
        list: LogosListView {
            model: messages  // roles: sender, subject
            delegate: LogosListRow {
                required property string sender
                required property string subject
                required property int index
                width: ListView.view.width
                title: sender
                subtitle: subject
                selected: inbox.twoPane && index === current.index
                onClicked: { open(index); inbox.detailOpen = true }
            }
        }
        detail: MessageView { message: current }
    }
}
```

A list and an open item take one of two layouts. If the open item is what
the page is for (a message, a settings page), `LogosListDetail`: a narrow list
beside a wide detail. If the page is (a table of packages, a chat thread) and
the item's details are secondary, `LogosSidePanel`: the page keeps the room and
a narrow panel opens beside it on demand. On a phone both show one page at a
time, with ‹ back.

```qml
LogosSidePanel {
    id: packages
    title: openRow ? openRow.name : ""
    onPanelOpenChanged: if (!panelOpen) openRow = null
    content: LogosTable {
        model: store.packages
        onRowClicked: (index, row) => { openRow = row; packages.panelOpen = true }
        columns: [ … ]
    }
    panel: PackageDetails { row: openRow }
    panelActions: [ LogosButton { text: qsTr("Install"); variant: LogosButton.Variant.Primary } ]
}
```

A page with several sections, as Basecamp's Settings, uses `LogosSections`:
its title, subtitle and `accessory` (a search, for the sections that have one)
head the page, and each section's page goes in the card beside the list. On a
phone the sections open under a "‹ Settings" row, so the pages need no bar of
their own. A section that opens a level of its own, such as a table row's
detail as the page, sets `canGoBack` and `backTitle`: the same row names it
and `backRequested()` goes up one level; beside the list the row shows at the
top of the section's card. There is one way back, so the levels draw no back
of their own.

A row, a header or a field and its button whose parts move under each other
when they don't fit uses `LogosItemLayout` rather than its own width checks:
it measures what fits, so it keeps one line wherever that works, at any
width class.

```qml
LogosItemLayout {
    width: parent.width
    leading: LogosTile { label: publisher.name; interactive: false }
    ColumnLayout {
        LogosText { Layout.fillWidth: true; text: publisher.name; elide: Text.ElideRight }
        LogosText { Layout.fillWidth: true; text: publisher.url; elide: Text.ElideRight }
    }
    meta: [ LogosText { Layout.fillWidth: true; text: publisher.fingerprint; wrapMode: Text.Wrap },
            LogosCopyButton { value: publisher.did } ]
    trailing: LogosIconButton { iconSource: LogosIcons.trash }
}
```

## Controls that adapt

- **`LogosButtonRow`**: buttons side by side, or stacked full width on a phone
  (main ones last, under the thumb) and wherever they don't fit in a row.
- **`LogosStateView`**: loading, empty and error states with their actions,
  kept to a readable width; actions stack on a phone.
- **`LogosDialog`**: centred at `preferredWidth`, never wider than its parent
  less the page margins. In a phone-wide parent a sheet across the bottom,
  dragged down to close, or with `fullPage` the whole parent, for a form. Put
  your content in `body`: it scrolls while the title and actions stay. A
  dialog that sets `anchors.centerIn` or `width` keeps that placement off a
  phone; on one it is a sheet or a page across its window, and the app's
  placement comes back when it closes.
- **`LogosMenu`**: in a phone-wide window a sheet across the bottom, however
  it is opened. It goes by its window, since its parent is the button that
  opens it.
- **`LogosComboBox`**: its list too, in a phone-wide window, rather than a
  dropdown under the box.
- **`LogosTable`**: give columns that can go a `priority` (higher drops
  first) and they drop out before the table scrolls sideways. With
  `phoneCards` a phone-wide table shows a card per row instead (the first
  column as the title, the others under it; a column's `card` makes it a
  badge or leaves it off), or your own `cardDelegate`. Give `rowMenu` a
  `LogosMenu` for a visible ⋯ on every row and card, and open a row on a tap
  (`rowsOpen` shows its ›): nothing needs hover or a double-click. A table
  that drops columns shows them somewhere: in the row's detail, a
  `LogosSidePanel` beside it. The storybook table page has the pattern
  (Alisher's RESPONSIVE.md §3.5).
- **`LogosPaginator`**: short of room it drops the page-size selector, then
  the info text, then shows ‹ 4 / 10 › instead of the page numbers.
- **`LogosSearchToggle`**: a search that folds into an icon, for a bar.

## Don't

- **Fix widths.** `width: 560` on a dialog, `implicitWidth: 400` on a field,
  `Layout.preferredWidth: 800` on a pane: each overflows a 390 px phone.
  Use the layouts, `Layout.fillWidth`, or
  `Math.min(preferred, parent.width - 2 * Theme.pageMargin(parent.width))`.
- **Read the window's width for layout.** Use the component's own.
- **Branch on the width class to make things fit.** `narrow ? a : b` in a
  page means a layout is missing; `LogosItemLayout` and the layouts above
  measure what fits instead.
- **Add a ☰ drawer** for navigation. Sections become a list the page goes back
  to; app-wide actions go in the page bar's ⋯.
- **Rely on hover**, or put information only in a tooltip.
- **Draw a control's sizes as numbers**; they won't grow at touch.

## Checking a page

- In the storybook, **Preview** opens the page in a phone (390) or tablet
  (700) window. It has its own overlay, so menus and dialogs behave as on
  the device, and `Theme.viewWidth` is its width, so a phone gets touch sizes.
  It marks in red whatever reaches past its sides, and in orange anything
  tappable smaller than 44 px; hover a mark to see what it is.
- **Density** switches compact, comfortable and touch.
- `tests/tst_PhoneFit.qml` runs the same checks
  (`storybook/PhoneChecks.js`) on every layout and the adapting controls at
  390 px. A new layout or control that adapts to its width gets a scene there,
  and its own tests at each width class.
- `tests/tst_StorybookPhoneFit.qml` loads every storybook page at 390 px and
  fails on anything past the sides, so the Preview shows no red. A demo at a
  fixed width takes `Layout.fillWidth` and `Layout.maximumWidth` instead of
  `Layout.preferredWidth`.

## Hosts

A host keeps each view's engine told the view's width with
`ThemeManager::followViewWidth(root)`, and loads `Logos.Layouts` with the
other design-system modules. A host that whitelists the modules apps may
import has to allow `Logos.Layouts` too.
