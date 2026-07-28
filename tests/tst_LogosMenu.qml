import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosMenu"
    width: 300
    height: 200
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

    function init() {
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

    function test_popupUnder_falls_back_without_anchor() {
        menu.popupUnder(null)
        tryCompare(menu, "opened", true)
        menu.close()
    }
}
