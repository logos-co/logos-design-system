import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosTable"
    width: 800
    height: 400
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    ListModel {
        id: peopleModel
        ListElement { name: "Alice";   role_: "Engineer" }
        ListElement { name: "Bob";     role_: "Designer" }
        ListElement { name: "Carol";   role_: "Manager"  }
    }

    Component {
        id: tableComp

        LogosTable {
            anchors.fill: parent
            model: peopleModel
            columns: [
                LogosTableColumn { title: "Name"; role: "name";   minWidth: 100; preferredWidth: 150; sortable: true },
                LogosTableColumn { title: "Role"; role: "role_";  minWidth: 100; preferredWidth: 200; sortable: true; fillWidth: true }
            ]
        }
    }

    function _create(parent) {
        return createTemporaryObject(tableComp, parent || root)
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    // ─── Defaults ───

    function test_defaults() {
        var t = _create()
        compare(t.selectionMode, LogosTable.None)
        compare(t.selectedIndices.length, 0)
        compare(t.allSelected, false)
        compare(t.sortRole, "")
        compare(t.sortOrder, Qt.AscendingOrder)
        compare(t.loading, false)
        compare(t.rowHeight, 64)
        compare(t.headerHeight, 36)
        verify(t.view !== null, "view alias must resolve to inner ListView")
    }

    function test_columns_assigned() {
        var t = _create()
        compare(t.columns.length, 2)
        compare(t.columns[0].title, "Name")
        compare(t.columns[1].fillWidth, true)
    }

    // ─── Sorting (consumer-driven) ───

    function test_header_click_emits_sortRequested_when_sortable() {
        var t = _create()
        var spy = sortSpy.createObject(root, { target: t })
        // Simulate header click via the internal helper (bypasses geometry).
        t.d._onHeaderClick(t.columns[0])
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "name")
        compare(spy.signalArguments[0][1], Qt.AscendingOrder)
    }

    function test_sort_cycles_asc_then_desc() {
        var t = _create()
        var spy = sortSpy.createObject(root, { target: t })

        t.d._onHeaderClick(t.columns[0])
        compare(spy.signalArguments[0][1], Qt.AscendingOrder)

        // Simulate the consumer applying sort state, then click again.
        t.sortRole = "name"
        t.sortOrder = Qt.AscendingOrder
        t.d._onHeaderClick(t.columns[0])
        compare(spy.signalArguments[1][1], Qt.DescendingOrder)
    }

    function test_non_sortable_header_does_not_emit_sort() {
        var t = _create()
        t.columns[0].sortable = false
        var spy = sortSpy.createObject(root, { target: t })
        t.d._onHeaderClick(t.columns[0])
        compare(spy.count, 0)
    }

    function test_headerClicked_always_fires() {
        var t = _create()
        t.columns[0].sortable = false
        var spy = headerSpy.createObject(root, { target: t })
        t.d._onHeaderClick(t.columns[0])
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "name")
    }

    // ─── Selection ───

    function test_selection_none_does_not_prepend_column() {
        var t = _create()
        compare(t.selectionMode, LogosTable.None)
        compare(t.d.effectiveColumns.length, 2)
    }

    function test_selection_multi_prepends_column() {
        var t = _create()
        t.selectionMode = LogosTable.Multi
        compare(t.d.effectiveColumns.length, 3)
        compare(t.d.effectiveColumns[0].minWidth, 40)
    }

    function test_toggle_row_in_multi_appends() {
        var t = _create()
        t.selectionMode = LogosTable.Multi
        var spy = selectionSpy.createObject(root, { target: t })

        t.d._toggleRow(0)
        compare(t.selectedIndices, [0])
        t.d._toggleRow(2)
        compare(t.selectedIndices, [0, 2])
        compare(spy.count, 2)
    }

    function test_toggle_row_in_multi_removes_when_present() {
        var t = _create()
        t.selectionMode = LogosTable.Multi
        t.d._toggleRow(0)
        t.d._toggleRow(1)
        t.d._toggleRow(0)   // remove
        compare(t.selectedIndices, [1])
    }

    function test_toggle_row_in_single_replaces() {
        var t = _create()
        t.selectionMode = LogosTable.Single
        t.d._toggleRow(0)
        compare(t.selectedIndices, [0])
        t.d._toggleRow(2)
        compare(t.selectedIndices, [2])
    }

    function test_toggle_row_in_single_clears_when_same() {
        var t = _create()
        t.selectionMode = LogosTable.Single
        t.d._toggleRow(1)
        t.d._toggleRow(1)
        compare(t.selectedIndices.length, 0)
    }

    function test_select_all_picks_every_row() {
        var t = _create()
        t.selectionMode = LogosTable.Multi
        t.d._toggleAll()
        compare(t.selectedIndices, [0, 1, 2])
        compare(t.allSelected, true)
    }

    function test_select_all_clears_when_already_all() {
        var t = _create()
        t.selectionMode = LogosTable.Multi
        t.d._toggleAll()
        t.d._toggleAll()   // unselect all
        compare(t.selectedIndices.length, 0)
        compare(t.allSelected, false)
    }

    // ─── Empty + loading ───

    function test_empty_when_model_count_zero() {
        var t = _create()
        var emptyModel = Qt.createQmlObject('import QtQuick; ListModel {}', t)
        t.model = emptyModel
        compare(t.empty, true)
    }

    function test_not_empty_with_data() {
        var t = _create()
        compare(t.empty, false)
    }

    // ─── Sizing inputs ───

    function test_totalMinWidth_sums_columns() {
        var t = _create()
        // Two columns at minWidth 100 each + selection col when active
        compare(t.d.totalMinWidth, 200)
        t.selectionMode = LogosTable.Multi
        compare(t.d.totalMinWidth, 240)
    }

    function test_column_sizing_defaults() {
        var col = Qt.createQmlObject('import Logos.Controls; LogosTableColumn {}', root)
        compare(col.minWidth, 80)
        compare(col.preferredWidth, 80)
        compare(col.maxWidth, -1)
        compare(col.fillWidth, false)
    }

    function test_preferredWidth_defaults_to_minWidth() {
        var col = Qt.createQmlObject('import Logos.Controls; LogosTableColumn { minWidth: 200 }', root)
        compare(col.preferredWidth, 200)
    }

    // ─── Row click signal ───

    function test_rowClicked_signal_can_be_emitted() {
        var t = _create()
        var spy = rowClickSpy.createObject(root, { target: t })
        t.rowClicked(1, peopleModel.get(1))
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 1)
    }

    // ─── Override hooks compile + take effect ───

    function test_emptyText_default() {
        var t = _create()
        compare(t.emptyText.length > 0, true)
    }

    function test_view_alias_is_listview() {
        var t = _create()
        // The aliased ListView must accept ListView-only methods.
        verify(typeof t.view.positionViewAtIndex === "function",
               "view alias must expose ListView API")
    }

    // ─── SignalSpy templates (re-used per test) ───

    // ─── Header tap areas (Alisher's ADR-061) ───

    Component {
        id: actionsTableComp

        LogosTable {
            anchors.fill: parent
            model: peopleModel
            columns: [
                LogosTableColumn { title: "Name"; role: "name"; minWidth: 100; fillWidth: true; sortable: true },
                LogosTableColumn { title: "Role"; role: "role_"; minWidth: 100 },
                LogosTableColumn { minWidth: 44; maxWidth: 44 }   // untitled actions column
            ]
        }
    }

    // Left to right.
    function _headerTapAreas(t) {
        const out = []
        const walk = item => {
            if (item.objectName === "headerTapArea")
                out.push(item)
            for (let i = 0; i < item.children.length; ++i)
                walk(item.children[i])
        }
        walk(t)
        return out.sort((a, b) => a.mapToItem(t, 0, 0).x - b.mapToItem(t, 0, 0).x)
    }

    function test_untitled_header_cell_is_not_a_tap_target() {
        const t = createRendered(actionsTableComp)
        const areas = _headerTapAreas(t)
        compare(areas.length, 3)
        compare(areas[0].enabled, true)    // sortable
        compare(areas[1].enabled, true)    // titled, not sortable: still emits headerClicked
        compare(areas[2].enabled, false)   // untitled, not sortable

        const spy = headerSpy.createObject(root, { target: t })
        const cell = areas[2].mapToItem(t, areas[2].width / 2, areas[2].height / 2)
        mouseClick(t, cell.x, cell.y)
        compare(spy.count, 0)
        spy.destroy()
    }

    function test_header_tap_area_spans_the_whole_cell() {
        const t = createRendered(actionsTableComp)
        const areas = _headerTapAreas(t)
        // The title is inset by the cell padding; the tap area is not.
        compare(areas[0].mapToItem(t, 0, 0).x, 0)
        compare(areas[0].width, areas[1].mapToItem(t, 0, 0).x)
        compare(areas[0].height, t.headerHeight)

        // A click in the padding, left of the title, still sorts.
        const spy = sortSpy.createObject(root, { target: t })
        mouseClick(t, 2, t.headerHeight / 2)
        compare(spy.count, 1)
        spy.destroy()
    }

    function test_touch_sortable_header_is_touch_sized() {
        ThemeManager.setDensity("touch")
        const t = createRendered(actionsTableComp)
        compare(t.headerHeight, Theme.size.touchTarget)
        const areas = _headerTapAreas(t)
        verify(areas[0].height >= Theme.size.touchTarget)
        verify(areas[0].width >= Theme.size.touchTarget)
    }

    Component { id: sortSpy;       SignalSpy { signalName: "sortRequested"  } }
    Component { id: headerSpy;     SignalSpy { signalName: "headerClicked"  } }
    Component { id: selectionSpy;  SignalSpy { signalName: "selectionChanged" } }
    Component { id: rowClickSpy;   SignalSpy { signalName: "rowClicked"     } }

    // ---- Density and touch ----

    Component { id: longPressSpy; SignalSpy {} }

    // Input reaches a new item once it has been rendered.
    function createRendered(component, properties) {
        const item = createTemporaryObject(component, root, properties || {})
        waitForRendering(item)
        return item
    }

    function holdOn(item) {
        mousePress(item)
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        mouseRelease(item)
    }

    function spyFor(target, signalName) {
        return createTemporaryObject(longPressSpy, root, { target: target, signalName: signalName })
    }

    ListModel {
        id: touchRows
        ListElement { name: "a" }
        ListElement { name: "b" }
    }

    Component {
        id: selectableTable
        LogosTable {
            width: 400
            height: 300
            selectionMode: LogosTable.Multi
            model: touchRows
            columns: [ LogosTableColumn { title: "Name"; role: "name" } ]
        }
    }

    // Next to the checkbox, inside its cell: the top-left corner of row 0.
    function clickBesideTheCheckbox(t) {
        const p = t.view.itemAtIndex(0).mapToItem(t, 2, 2)
        mouseClick(t, p.x, p.y)
    }

    function test_touch_header_is_touch_tall() {
        ThemeManager.setDensity("touch")
        compare(createRendered(selectableTable).headerHeight, Theme.size.touchTarget)
    }

    function test_touch_tap_beside_the_checkbox_toggles_the_row() {
        ThemeManager.setDensity("touch")
        const t = createRendered(selectableTable)
        const clicked = spyFor(t, "rowClicked")
        clickBesideTheCheckbox(t)
        compare(t.selectedIndices, [0])
        compare(clicked.count, 0)
    }

    function test_desktop_click_beside_the_checkbox_is_a_row_click() {
        const t = createRendered(selectableTable)
        const clicked = spyFor(t, "rowClicked")
        clickBesideTheCheckbox(t)
        compare(t.selectedIndices, [])
        compare(clicked.count, 1)
    }

    // A pixel at the empty right end of each row, selected row 0 vs row 1.
    function selectedRowLooksDifferent(t) {
        t.selectedIndices = [0]
        waitForRendering(t)
        const image = grabImage(t)
        const x = t.width - 5
        const y0 = t.view.itemAtIndex(0).mapToItem(t, 0, t.rowHeight / 2).y
        const y1 = t.view.itemAtIndex(1).mapToItem(t, 0, t.rowHeight / 2).y
        return !Qt.colorEqual(image.pixel(x, y0), image.pixel(x, y1))
    }

    function test_touch_shows_the_selected_row() {
        ThemeManager.setDensity("touch")
        verify(selectedRowLooksDifferent(createRendered(selectableTable)))
    }

    function test_desktop_does_not_highlight_the_selected_row() {
        verify(!selectedRowLooksDifferent(createRendered(selectableTable)))
    }

    // ---- Narrow tables and phones ----

    ListModel {
        id: packageRows
        ListElement { name: "wallet"; version: "1.2.0"; size: "4 MB"; status: "Installed" }
        ListElement { name: "chat";   version: "0.9.1"; size: "";     status: "Upgrade" }
    }

    // Minimum widths 120 + 80 + 80 + 100 = 380.
    Component {
        id: prioritisedTable
        LogosTable {
            height: 300
            model: packageRows
            columns: [
                LogosTableColumn { title: "Name";    role: "name";    minWidth: 120 },
                LogosTableColumn { title: "Version"; role: "version"; minWidth: 80; priority: 2 },
                LogosTableColumn { title: "Size";    role: "size";    minWidth: 80; priority: 1 },
                LogosTableColumn { title: "Status";  role: "status";  minWidth: 100 }
            ]
        }
    }

    Component {
        id: unprioritisedTable
        LogosTable {
            width: 150
            height: 300
            model: packageRows
            columns: [
                LogosTableColumn { title: "Name";   role: "name";   minWidth: 120 },
                LogosTableColumn { title: "Status"; role: "status"; minWidth: 100 }
            ]
        }
    }

    Component { id: appCard; LogosText { text: "#" + rowIndex + " " + rowItem.name } }

    function shownTitles(t) {
        return t.d.shownColumns.map(column => column.title)
    }

    function findText(item, text) {
        if (item.text === text && item.visible)
            return item
        for (let i = 0; i < item.children.length; ++i) {
            const found = findText(item.children[i], text)
            if (found)
                return found
        }
        return null
    }

    function phoneTable(properties) {
        return createRendered(prioritisedTable, Object.assign({ width: 390, phoneCards: true }, properties || {}))
    }

    function card(t, index) {
        return t.cardsView.itemAtIndex(index).item
    }

    // A card's checkbox, in the row at its end.
    function box(c) {
        return c.accessory.children.find(child => child instanceof LogosCheckbox)
    }

    function test_priority_defaults_to_always_shown() {
        compare(Qt.createQmlObject('import Logos.Controls; LogosTableColumn {}', root).priority, 0)
    }

    function test_columns_drop_out_highest_priority_first() {
        const t = createTemporaryObject(prioritisedTable, root, { width: 380 })
        compare(shownTitles(t), ["Name", "Version", "Size", "Status"])
        t.width = 379
        compare(shownTitles(t), ["Name", "Size", "Status"])
        t.width = 300
        compare(shownTitles(t), ["Name", "Size", "Status"])
        t.width = 299
        compare(shownTitles(t), ["Name", "Status"])
        t.width = 380
        compare(shownTitles(t), ["Name", "Version", "Size", "Status"])
    }

    function test_columns_without_a_priority_scroll_instead() {
        const t = createTemporaryObject(prioritisedTable, root, { width: 150 })
        compare(shownTitles(t), ["Name", "Status"])
        compare(t.d.totalMinWidth, 220)
    }

    function test_without_priorities_nothing_drops() {
        const t = createTemporaryObject(unprioritisedTable, root)
        compare(t.d.shownColumns, t.d.effectiveColumns)
        compare(t.d.totalMinWidth, 220)
    }

    function test_the_selection_column_counts_and_stays() {
        const t = createTemporaryObject(prioritisedTable, root, { width: 380, selectionMode: LogosTable.Multi })
        compare(t.d.shownColumns[0], t.d._selectionColumn)
        compare(shownTitles(t).slice(1), ["Name", "Size", "Status"])
    }

    function test_a_dropped_column_leaves_the_header_and_the_rows() {
        const t = createRendered(prioritisedTable, { width: 379 })
        verify(findText(t, "Size"))
        verify(!findText(t, "Version"))
        verify(findText(t.view.itemAtIndex(0), "4 MB"))
        verify(!findText(t.view.itemAtIndex(0), "1.2.0"))
    }

    // The cells of row 0, left to right.
    function rowCells(t) {
        const row = t.view.itemAtIndex(0).item
        for (let i = 0; i < row.children.length; ++i)
            if (row.children[i] instanceof RowLayout)
                return row.children[i].children.filter(cell => !(cell instanceof Repeater))
        return []
    }

    function test_when_the_filling_column_drops_the_rest_share_its_room() {
        const t = createRendered(prioritisedTable, { width: 379 })
        t.columns[2].fillWidth = true
        t.width = 299
        compare(shownTitles(t), ["Name", "Status"])
        waitForRendering(t)
        const cells = rowCells(t)
        compare(cells.length, 2)
        compare(cells[0].width + cells[1].width, 299)
    }

    function test_without_drops_the_leftover_stays_as_it_was() {
        const t = createRendered(prioritisedTable, { width: 500 })
        const cells = rowCells(t)
        compare(cells.length, 4)
        compare(cells.reduce((sum, cell) => sum + cell.width, 0), 380)
    }

    function test_cards_only_on_a_phone_and_when_asked() {
        const t = createTemporaryObject(prioritisedTable, root, { width: 390 })
        verify(!t.showingCards)
        t.phoneCards = true
        verify(t.showingCards)
        t.width = 600
        verify(!t.showingCards)
        compare(t.cardsView.count, 0)
    }

    function test_cards_replace_the_rows() {
        const t = phoneTable()
        compare(t.cardsView.count, 2)
        verify(t.cardsView.visible)
        verify(!t.view.visible)
        verify(!findText(t, "Version"))
    }

    function test_a_card_has_the_first_column_over_the_rest() {
        const t = phoneTable()
        compare(card(t, 0).title, "wallet")
        compare(card(t, 0).subtitle, "1.2.0 · 4 MB · Installed")
        compare(card(t, 1).subtitle, "0.9.1 · Upgrade")
        compare(card(t, 0).accessory, null)
    }

    function test_a_tap_on_a_card_opens_its_row() {
        const t = phoneTable()
        const clicked = spyFor(t, "rowClicked")
        mouseClick(card(t, 1))
        compare(clicked.count, 1)
        compare(clicked.signalArguments[0][0], 1)
        compare(clicked.signalArguments[0][1].name, "chat")
    }

    function test_a_tap_selects_in_a_selectable_table() {
        const t = phoneTable({ selectionMode: LogosTable.Multi })
        const clicked = spyFor(t, "rowClicked")
        const second = card(t, 1)
        mouseClick(second)
        compare(t.selectedIndices, [1])
        verify(second.selected)
        verify(box(second).checked)
        mouseClick(second)
        compare(t.selectedIndices, [])
        verify(!box(second).checked)
        compare(clicked.count, 0)
    }

    function test_a_tap_on_the_checkbox_selects_once() {
        const t = phoneTable({ selectionMode: LogosTable.Multi })
        mouseClick(box(card(t, 1)))
        compare(t.selectedIndices, [1])
    }

    function test_cards_follow_the_selection() {
        const t = phoneTable({ selectionMode: LogosTable.Multi })
        mouseClick(card(t, 0))
        t.selectedIndices = [1]
        verify(!box(card(t, 0)).checked)
        verify(box(card(t, 1)).checked)
        verify(card(t, 1).selected)
    }

    function test_single_selection_moves_between_cards() {
        const t = phoneTable({ selectionMode: LogosTable.Single })
        mouseClick(card(t, 0))
        mouseClick(card(t, 1))
        compare(t.selectedIndices, [1])
        verify(!box(card(t, 0)).checked)
    }

    function test_an_app_card_gets_the_row() {
        const t = phoneTable({ cardDelegate: appCard })
        compare(card(t, 1).text, "#1 chat")
    }

    // ---- Row actions and §3.5 cards (Alisher's RESPONSIVE.md) ----

    Component {
        id: menuTable
        LogosTable {
            height: 300
            model: packageRows
            rowMenu: LogosMenu { LogosMenuItem { text: "Uninstall" } }
            columns: [
                LogosTableColumn { title: "Name";    role: "name";    minWidth: 120 },
                LogosTableColumn { title: "Version"; role: "version"; minWidth: 80 },
                LogosTableColumn { title: "Size";    role: "size";    minWidth: 80; card: "hidden" },
                LogosTableColumn { title: "Status";  role: "status";  minWidth: 100; card: "badge" }
            ]
        }
    }

    function findNamed(item, name) {
        if (item.objectName === name && item.visible)
            return item
        for (let i = 0; i < item.children.length; ++i) {
            const found = findNamed(item.children[i], name)
            if (found)
                return found
        }
        return null
    }

    function test_without_a_row_menu_there_is_no_menu_column() {
        const t = createRendered(prioritisedTable, { width: 500 })
        compare(t.d.effectiveColumns.length, 4)
        verify(!findNamed(t.view.itemAtIndex(0), "rowMenuButton"))
    }

    function test_a_row_menu_puts_a_menu_on_each_row_at_the_end() {
        const t = createRendered(menuTable, { width: 600 })
        const columns = t.d.shownColumns
        compare(columns[columns.length - 1], t.d._menuColumn)
        const button = findNamed(t.view.itemAtIndex(1), "rowMenuButton")
        verify(button)
        verify(button.width >= Theme.size.touchTarget)
    }

    function test_the_menu_column_never_drops_and_its_header_is_not_a_target() {
        const t = createRendered(menuTable, { width: 200 })
        const columns = t.d.shownColumns
        compare(columns[columns.length - 1], t.d._menuColumn)
        const areas = _headerTapAreas(t)
        compare(areas[areas.length - 1].enabled, false)
    }

    function test_the_row_menu_opens_for_its_row() {
        const t = createRendered(menuTable, { width: 600 })
        mouseClick(findNamed(t.view.itemAtIndex(1), "rowMenuButton"))
        tryCompare(t.rowMenu, "opened", true)
        compare(t.menuRowIndex, 1)
        compare(t.menuRow.name, "chat")
        t.rowMenu.close()
    }

    function test_a_card_has_the_menu_too() {
        const t = phoneTable({ rowMenu: Qt.createQmlObject('import Logos.Controls; LogosMenu {}', root) })
        mouseClick(findNamed(card(t, 0), "cardMenuButton"))
        tryCompare(t.rowMenu, "opened", true)
        compare(t.menuRowIndex, 0)
        compare(t.menuRow.name, "wallet")
        t.rowMenu.close()
    }

    function test_a_card_puts_its_columns_where_they_say() {
        const t = createRendered(menuTable, { width: 390, phoneCards: true })
        const c = card(t, 0)
        compare(c.title, "wallet")
        compare(c.subtitle, "1.2.0")             // Size hidden, Status a badge
        const badge = findNamed(c, "cardBadge")
        verify(badge)
        compare(badge.item.text, "Installed")
    }

    function test_rows_that_open_show_a_chevron_on_their_cards() {
        const t = phoneTable()
        verify(!card(t, 0).chevronItem.visible)
        t.rowsOpen = true
        verify(card(t, 0).chevronItem.visible)
        t.selectionMode = LogosTable.Multi
        verify(!card(t, 0).chevronItem.visible)   // a tap selects there
    }
}
