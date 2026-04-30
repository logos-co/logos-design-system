import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Controls

TestCase {
    name: "LogosDrawer"
    width: 400
    height: 300
    when: windowShown

    LogosDrawer {
        id: drawer
        edge: Qt.LeftEdge
        width: 200
    }

    function test_alias_resolves() {
        verify(drawer.backgroundItem)
    }

    function test_default_edge_left_after_set() {
        compare(drawer.edge, Qt.LeftEdge)
    }

    function test_can_open_close() {
        drawer.open()
        tryCompare(drawer, "opened", true)
        drawer.close()
        tryCompare(drawer, "opened", false)
    }
}
