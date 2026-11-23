import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Theme
import Logos.Controls

// LogosComboBox in a phone-wide window: its list is a sheet across the
// bottom, as LogosMenu's is. It had opened as a desktop dropdown under the
// box, the one control on a phone that still did.
TestCase {
    id: root
    name: "LogosComboBoxSheet"
    width: 390
    height: 700
    // Input reaches nothing in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component {
        id: comboComp
        LogosComboBox {
            x: 20
            y: 20
            width: 160
            model: ["All categories", "Networking", "Storage", "Wallets", "Chat"]
        }
    }

    Component {
        id: longComboComp
        LogosComboBox {
            x: 20
            y: 20
            width: 160
            model: 60
        }
    }

    Component { id: spyComp; SignalSpy {} }

    Component {
        id: holderComp
        Item {
            width: 200
            height: 60
            readonly property alias combo: heldCombo
            LogosComboBox {
                id: heldCombo
                x: 20
                y: 20
                width: 160
                model: ["All categories", "Networking", "Storage"]
            }
        }
    }

    function overlayOf(combo) {
        return combo.popupItem.Overlay.overlay
    }

    // The list's rectangle in the window.
    function placement(combo) {
        const bg = combo.popupItem.background
        const p = bg.mapToItem(overlayOf(combo), 0, 0)
        return { x: p.x, y: p.y, width: bg.width, bottom: p.y + bg.height }
    }

    function open(component) {
        const combo = createTemporaryObject(component || comboComp, root)
        waitForRendering(combo)
        mouseClick(combo)
        tryCompare(combo.popupItem, "opened", true)
        tryVerify(() => Math.abs(placement(combo).bottom - overlayOf(combo).height) < 0.5, 2000,
                  "the sheet's bottom is the window's")
        return combo
    }

    function test_opens_as_a_sheet_across_the_bottom() {
        const combo = open()
        verify(combo.sheet)
        const where = placement(combo)
        compare(where.x, 0)
        compare(where.width, 390)
        verify(combo.popupHandleItem.visible)
        compare(combo.popupListView.itemAtIndex(0).width, combo.popupListView.width, "the entries span it")
    }

    function test_the_page_dims_and_a_tap_on_it_closes_without_picking() {
        const combo = open()
        verify(combo.popupItem.modal)
        mouseClick(root, root.width / 2, 50)
        tryCompare(combo.popupItem, "visible", false)
        compare(combo.currentIndex, 0)
    }

    function test_a_tap_on_an_entry_picks_it() {
        const combo = open()
        const activated = createTemporaryObject(spyComp, root, { target: combo, signalName: "activated" })
        mouseClick(combo.popupListView.itemAtIndex(2))
        compare(activated.count, 1)
        compare(combo.currentIndex, 2)
        tryCompare(combo.popupItem, "visible", false)
        verify(!combo.sheet, "closed, it is a sheet no longer")
    }

    function test_dragging_the_handle_down_closes() {
        const combo = open()
        const handle = combo.popupHandleItem
        mouseDrag(handle, handle.width / 2, handle.height / 2, 0, combo.popupItem.height / 2)
        tryCompare(combo.popupItem, "visible", false)
    }

    function test_a_short_drag_snaps_back() {
        const combo = open()
        const handle = combo.popupHandleItem
        mouseDrag(handle, handle.width / 2, handle.height / 2, 0, combo.popupItem.height / 8)
        tryVerify(() => Math.abs(placement(combo).bottom - overlayOf(combo).height) < 0.5, 2000, "back in place")
        verify(combo.popupItem.opened)
    }

    function test_a_long_list_leaves_the_page_showing_above_and_scrolls() {
        const combo = open(longComboComp)
        compare(placement(combo).y, Theme.controls.dialog.sheetTopGap)
        verify(combo.popupListView.contentHeight > combo.popupListView.height)
    }

    // The box leaves the window and goes, as a list's row does under a
    // refresh: after its list was a sheet, or while it is one.
    function test_it_goes_away_cleanly_data() {
        return [{ tag: "closed", open: false }, { tag: "open", open: true }]
    }

    function test_it_goes_away_cleanly(data) {
        failOnWarning(/TypeError/)
        const holder = holderComp.createObject(root)
        waitForRendering(holder)
        mouseClick(holder.combo)
        tryCompare(holder.combo.popupItem, "opened", true)
        verify(holder.combo.sheet)
        if (!data.open) {
            holder.combo.popupItem.close()
            tryCompare(holder.combo.popupItem, "visible", false)
        }
        holder.parent = null
        holder.destroy()
        wait(50)
    }
}
