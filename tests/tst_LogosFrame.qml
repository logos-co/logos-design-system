import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosFrame"
    width: 300
    height: 200
    when: windowShown

    LogosFrame {
        id: frame
        anchors.fill: parent
    }

    function test_alias_resolves() {
        verify(frame.backgroundItem)
    }

    function test_padding_default() {
        verify(frame.padding > 0)
    }
}
