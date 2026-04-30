import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosToolBar"
    width: 400
    height: 60
    when: windowShown

    LogosToolBar {
        id: bar
        anchors.fill: parent
        LogosToolButton { text: "A" }
        LogosToolButton { text: "B" }
    }

    function test_alias_resolves() {
        verify(bar.backgroundItem)
    }

    function test_separator_color_is_themed() {
        verify(bar.separatorColor.toString().length > 0)
    }
}
