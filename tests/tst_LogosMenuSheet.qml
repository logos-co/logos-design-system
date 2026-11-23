import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

// LogosMenu in a phone-wide window: a sheet across the bottom.
TestCase {
    id: root
    name: "LogosMenuSheet"
    width: 390
    height: 700
    // Input reaches nothing in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Item {
        id: anchor
        x: 300
        y: 20
        width: 40
        height: 40
    }

    Component {
        id: menuComp
        LogosMenu {
            LogosMenuItem { text: "Reload" }
            LogosMenuItem { text: "Settings" }
            LogosMenuItem { text: "Sign out" }
        }
    }

    Component {
        id: longMenuComp
        LogosMenu {
            Repeater {
                model: 40
                LogosMenuItem { text: "Item " + index }
            }
        }
    }

    Component { id: itemComp; LogosMenuItem {} }

    Component {
        id: holderComp
        Item {
            width: 40
            height: 40
            readonly property alias menu: heldMenu
            LogosMenu {
                id: heldMenu
                LogosMenuItem { text: "Reload" }
            }
        }
    }
    Component { id: spyComp; SignalSpy {} }

    function cleanup() {
        Theme.safeAreaBottom = 0
        ThemeManager.setDensity("")
    }

    function overlayOf(menu) {
        return menu.Overlay.overlay
    }

    // The menu's rectangle in the window.
    function placement(menu) {
        const p = menu.backgroundItem.mapToItem(overlayOf(menu), 0, 0)
        return { x: p.x, y: p.y, width: menu.backgroundItem.width, bottom: p.y + menu.backgroundItem.height }
    }

    function settled(menu) {
        tryVerify(() => Math.abs(placement(menu).bottom - overlayOf(menu).height) < 0.5, 2000,
                  "the sheet's bottom is the window's")
    }

    function openUnder() {
        const menu = createTemporaryObject(menuComp, anchor)
        menu.popupUnder(anchor)
        tryCompare(menu, "opened", true)
        settled(menu)
        return menu
    }

    function closeAndWait(menu) {
        menu.close()
        tryCompare(menu, "visible", false)
    }

    function test_the_window_is_phone_wide() {
        const menu = createTemporaryObject(menuComp, anchor)
        compare(overlayOf(menu).width, 390)
    }

    function test_opens_as_a_sheet_across_the_bottom() {
        const menu = openUnder()
        verify(menu.sheet)
        const where = placement(menu)
        compare(where.x, 0)
        compare(where.width, 390)
        verify(menu.handleItem.visible)
    }

    function test_any_way_of_opening_makes_a_sheet() {
        const menu = createTemporaryObject(menuComp, anchor)
        const ways = [() => menu.popup(), () => menu.popup(10, 10), () => menu.open()]
        for (let i = 0; i < ways.length; ++i) {
            ways[i]()
            tryCompare(menu, "opened", true)
            verify(menu.sheet, i)
            settled(menu)
            compare(placement(menu).x, 0)
            closeAndWait(menu)
        }
    }

    function test_the_items_span_the_width() {
        const menu = openUnder()
        compare(menu.itemAt(0).width, menu.availableWidth)
        compare(menu.availableWidth, 390 - menu.leftPadding - menu.rightPadding)
    }

    function test_the_page_dims_and_a_tap_on_it_closes() {
        const menu = openUnder()
        verify(menu.modal)
        verify(menu.dim)
        mouseClick(root, root.width / 2, 50)
        tryCompare(menu, "visible", false)
    }

    function test_a_tap_on_an_item_triggers_it() {
        const menu = openUnder()
        const triggered = createTemporaryObject(spyComp, root, { target: menu.itemAt(1), signalName: "triggered" })
        mouseClick(menu.itemAt(1))
        compare(triggered.count, 1)
        tryCompare(menu, "visible", false)
    }

    function test_dragging_the_handle_down_closes() {
        const menu = openUnder()
        const handle = menu.handleItem
        mouseDrag(handle, handle.width / 2, handle.height / 2, 0, menu.height / 2)
        tryCompare(menu, "visible", false)
    }

    function test_a_short_drag_snaps_back() {
        const menu = openUnder()
        const handle = menu.handleItem
        mouseDrag(handle, handle.width / 2, handle.height / 2, 0, menu.height / 8)
        settled(menu)
        verify(menu.opened)
    }

    function test_a_long_menu_leaves_the_page_showing_above_and_scrolls() {
        const menu = createTemporaryObject(menuComp, anchor)
        for (let i = 0; i < 40; ++i)
            menu.addItem(itemComp.createObject(null, { text: "Item " + i }))
        menu.popupUnder(anchor)
        tryCompare(menu, "opened", true)
        settled(menu)
        compare(placement(menu).y, Theme.controls.dialog.sheetTopGap)
        verify(menu.contentItem.interactive)
    }

    function test_it_fits_items_that_grew_before_it_opened() {
        const menu = createTemporaryObject(menuComp, anchor)
        ThemeManager.setDensity("touch")
        menu.popupUnder(anchor)
        tryCompare(menu, "opened", true)
        settled(menu)
        const last = menu.itemAt(menu.count - 1)
        compare(last.height, Theme.controls.menuItem.height)
        compare(menu.height, menu.implicitHeight)
        verify(last.mapToItem(overlayOf(menu), 0, last.height).y <= overlayOf(menu).height - menu.bottomPadding + 0.5)
    }

    // The item it is the menu of goes away, and the menu with it, as a list's
    // row does under a refresh: after it was a sheet, or while it is one. The
    // sheet's place followed the window's overlay, which is then gone.
    function test_its_item_goes_away_cleanly_data() {
        return [{ tag: "closed", open: false }, { tag: "open", open: true }]
    }

    function test_its_item_goes_away_cleanly(data) {
        failOnWarning(/TypeError/)
        const holder = holderComp.createObject(root)
        holder.menu.popupUnder(holder)
        tryCompare(holder.menu, "opened", true)
        settled(holder.menu)
        if (!data.open)
            closeAndWait(holder.menu)
        // Out of the window first, as a view's delegate leaves it.
        holder.parent = null
        holder.destroy()
        wait(50)
    }

    function test_closed_it_sizes_itself_again() {
        const menu = openUnder()
        closeAndWait(menu)
        verify(!menu.sheet)
        compare(menu.width, menu.implicitWidth)
        compare(menu.height, menu.implicitHeight)
        compare(menu.topPadding, menu.padding)
    }

    // A swipe on the items scrolls them, both ways; only the handle's strip
    // drags the sheet.
    function test_a_swipe_on_the_items_scrolls_and_leaves_the_sheet() {
        const menu = createTemporaryObject(longMenuComp, anchor)
        menu.popupUnder(anchor)
        tryCompare(menu, "opened", true)
        settled(menu)
        const list = menu.contentItem, bottom = placement(menu).bottom
        verify(list.contentHeight > list.height)
        const cx = list.width / 2
        const up = touchEvent(list)
        up.press(0, list, cx, list.height - 10).commit()
        for (let i = 1; i <= 12; ++i) { up.move(0, list, cx, list.height - 10 - i * 20).commit(); wait(16) }
        up.release(0, list, cx, list.height - 250).commit()
        tryVerify(() => list.contentY > 0, 2000, "swiping up scrolls the items")
        tryVerify(() => !list.moving)
        const scrolled = list.contentY
        const down = touchEvent(list)
        down.press(0, list, cx, 10).commit()
        for (let i = 1; i <= 8; ++i) {
            down.move(0, list, cx, 10 + i * 20).commit()
            wait(16)
            compare(placement(menu).bottom, bottom, "the sheet stays while the items scroll")
        }
        down.release(0, list, cx, 170).commit()
        tryVerify(() => list.contentY < scrolled, 2000, "swiping down scrolls them back")
        verify(menu.visible)
    }

    function test_the_items_stay_clear_of_the_safe_area() {
        Theme.safeAreaBottom = 30
        const menu = openUnder()
        compare(menu.bottomPadding, Theme.spacing.large + 30)
    }
}
