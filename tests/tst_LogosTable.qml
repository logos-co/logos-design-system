import QtQuick
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
}
