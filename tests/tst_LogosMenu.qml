import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosMenu"
    width: 300
    height: 200
    when: windowShown

    LogosMenu {
        id: menu
        LogosMenuItem { text: "One" }
        LogosMenuItem { text: "Two" }
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
}
