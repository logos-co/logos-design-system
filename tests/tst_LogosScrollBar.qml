import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Controls

TestCase {
    name: "LogosScrollBar"
    width: 200
    height: 200
    when: windowShown

    Flickable {
        id: scroll
        anchors.fill: parent
        contentWidth: width
        contentHeight: 800
        ScrollBar.vertical: LogosScrollBar { id: bar }
    }

    function test_default_thickness() { compare(bar.barThickness, 6) }

    function test_aliases_resolve() {
        verify(bar.barItem)
    }

    function test_bar_thickness_setter() {
        bar.barThickness = 10
        tryCompare(bar.barItem, "implicitWidth", 10)
    }
}
