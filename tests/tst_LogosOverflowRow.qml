import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

// A row of items while they fit, otherwise ⋯ and the app's menu; by what
// fits, not the width class. Three items of 100 with the default spacing
// (12) need 324.
TestCase {
    id: root
    name: "LogosOverflowRow"
    width: 700
    height: 300
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: toolbar
        LogosOverflowRow {
            height: Theme.size.touchTarget
            readonly property alias last: third
            Rectangle { implicitWidth: 100; implicitHeight: 40 }
            Rectangle { implicitWidth: 100; implicitHeight: 40 }
            Rectangle { id: third; Layout.preferredWidth: 100; implicitWidth: 20; implicitHeight: 40 }
            menu: LogosMenu {
                LogosMenuItem { text: "Install Local Package…" }
                LogosMenuItem { text: "Reload" }
                LogosMenuItem { text: "Manage Repositories…" }
            }
        }
    }

    Component {
        id: noMenu
        LogosOverflowRow {
            Rectangle { implicitWidth: 100; implicitHeight: 40 }
            Rectangle { implicitWidth: 100; implicitHeight: 40 }
        }
    }

    function init() {
        failOnWarning(/Binding loop/)
    }

    function create(component, width) {
        const item = createTemporaryObject(component, root, { width: width })
        verify(item)
        waitForRendering(item)
        return item
    }

    function rightOf(item, within) { return item.mapToItem(within, item.width, 0).x }

    function test_a_row_while_it_fits() {
        const r = create(toolbar, 400)
        verify(!r.folded)
        compare(r.rowItem.opacity, 1)
        verify(r.rowItem.enabled)
        verify(!r.moreButtonItem.visible)
        compare(r.implicitWidth, 324)
        compare(rightOf(r.last, r), 400, "at the end, where ⋯ would be")
        compare(r.last.width, 100, "at its Layout.preferredWidth")
    }

    function test_folds_into_more_when_it_does_not_fit() {
        const r = create(toolbar, 300)
        verify(r.folded)
        compare(r.rowItem.opacity, 0, "out of sight")
        verify(!r.rowItem.enabled, "and out of reach")
        verify(r.moreButtonItem.visible)
        compare(rightOf(r.moreButtonItem, r), 300, "⋯ at the end")
        verify(r.moreButtonItem.width >= Theme.size.touchTarget)
        mouseClick(r.moreButtonItem)
        tryCompare(r.menu, "opened", true)
        r.menu.close()
    }

    // Folding hides the row; it goes on measuring its items, so it unfolds
    // as soon as there is room again, with no flicker between the two.
    function test_folds_and_unfolds_with_its_width() {
        const r = create(toolbar, 300)
        verify(r.folded)
        r.width = 324
        waitForRendering(r)
        verify(!r.folded)
        r.width = 323
        waitForRendering(r)
        verify(r.folded)
    }

    // A phone's width on which the row fits keeps the row.
    function test_measured_not_by_width_class() {
        const r = create(toolbar, 360)
        compare(Theme.windowClass(r.width), "phone")
        verify(!r.folded)
    }

    // A hidden item takes no room, folded or not: hidden while folded, the
    // row had not noticed, and stayed folded with room to spare.
    function test_a_hidden_item_takes_no_room() {
        const r = create(toolbar, 300)
        verify(r.folded)
        r.last.visible = false
        tryVerify(() => !r.folded, 1000, "two items fit 300")
        compare(r.implicitWidth, 212)
    }

    // Without a menu it never folds: there would be nowhere for its items to
    // go, so they stay in sight and reach, as tall as they are.
    function test_without_a_menu_it_never_folds() {
        const r = create(noMenu, 100)
        verify(!r.folded)
        compare(r.rowItem.opacity, 1)
        verify(r.rowItem.enabled)
        verify(!r.moreButtonItem.visible)
        compare(r.implicitHeight, r.rowItem.implicitHeight)
    }
}
