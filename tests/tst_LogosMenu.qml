import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosMenu"
    // Desktop-wide: in a phone-wide window it is a sheet (tst_LogosMenuSheet).
    width: 800
    height: 200
    // Input reaches nothing in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Item {
        id: anchor
        width: 120
        height: 36
        x: 40
        y: 50
    }

    LogosMenu {
        id: menu
        LogosMenuItem { text: "One" }
        LogosMenuItem { text: "Two" }
    }

    Rectangle { id: contextTarget; x: 300; y: 40; width: 200; height: 80 }
    LogosButton { id: contextButton; x: 300; y: 140; text: "Hold me" }
    LogosMenu {
        id: contextMenu
        contextFor: contextTarget
        LogosMenuItem { text: "Copy" }
    }
    LogosMenu {
        id: buttonMenu
        contextFor: contextButton
        LogosMenuItem { text: "Copy" }
    }

    Component { id: spyComp; SignalSpy {} }

    function init() {
        contextMenu.close()
        buttonMenu.close()
        menu.close()
    }

    function test_alias_resolves() {
        verify(menu.backgroundItem)
    }

    function test_count_includes_items() {
        compare(menu.count, 2)
    }

    function test_can_open_and_close() {
        menu.open()
        tryCompare(menu, "opened", true)
        menu.close()
        tryCompare(menu, "opened", false)
    }

    function test_popupUnder_opens() {
        menu.popupUnder(anchor)
        tryCompare(menu, "opened", true)
        menu.close()
        tryCompare(menu, "opened", false)
    }

    function test_popupUnder_places_below_anchor_with_tiny_gap() {
        menu.popupUnder(anchor)
        tryCompare(menu, "opened", true)
        // popup(parent, x, y) maps into the overlay; compare in that space.
        const expected = anchor.mapToItem(menu.parent,
                                          0,
                                          anchor.height + Theme.spacing.tiny)
        compare(menu.x, expected.x)
        compare(menu.y, expected.y)
        menu.close()
    }

    function test_not_a_sheet_on_a_desktop() {
        menu.popupUnder(anchor)
        verify(menu.opened)
        verify(!menu.sheet)
        verify(!menu.modal)
        compare(menu.width, menu.implicitWidth)
        compare(menu.topPadding, Theme.spacing.tiny)
        menu.close()
        verify(!menu.visible)
    }

    function test_popupUnder_falls_back_without_anchor() {
        menu.popupUnder(null)
        tryCompare(menu, "opened", true)
        menu.close()
    }

    // A context menu: a right-click opens it where it was.
    function test_a_right_click_opens_the_context_menu_there() {
        mouseClick(contextTarget, 30, 20, Qt.RightButton)
        tryCompare(contextMenu, "opened", true)
        const at = contextMenu.backgroundItem.mapToItem(contextTarget, 0, 0)
        fuzzyCompare(at.x, 30, 2)
        fuzzyCompare(at.y, 20, 2)
    }

    function test_a_left_click_doesnt() {
        mouseClick(contextTarget, 30, 20)
        wait(100)
        verify(!contextMenu.opened)
    }

    // The touch path: a long press, on a plain item and on a button.
    function test_a_long_press_opens_it() {
        const t = touchEvent(contextTarget)
        t.press(0, contextTarget, 30, 20).commit()
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        t.release(0, contextTarget, 30, 20).commit()
        tryCompare(contextMenu, "opened", true)
    }

    function test_a_long_press_on_a_button_opens_it() {
        const clicked = createTemporaryObject(spyComp, root, { target: contextButton, signalName: "clicked" })
        mousePress(contextButton)
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        mouseRelease(contextButton)
        tryCompare(buttonMenu, "opened", true)
        compare(clicked.count, 0, "a long press isn't also a click")
    }
}
