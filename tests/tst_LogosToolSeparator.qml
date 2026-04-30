import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosToolSeparator"
    width: 100
    height: 50
    when: windowShown

    LogosToolSeparator { id: sep }

    function init() {
        sep.orientation = Qt.Vertical
    }

    function test_alias_resolves() {
        verify(sep.separatorItem)
    }

    function test_vertical_orientation_default() {
        compare(sep.orientation, Qt.Vertical)
    }

    function test_horizontal_orientation_swaps_dims() {
        sep.orientation = Qt.Horizontal
        tryVerify(function() { return sep.separatorItem.implicitWidth > sep.separatorItem.implicitHeight })
    }
}
