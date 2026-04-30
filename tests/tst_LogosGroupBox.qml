import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosGroupBox"
    width: 300
    height: 200
    when: windowShown

    LogosGroupBox {
        id: group
        title: "Settings"
        anchors.fill: parent
    }

    function init() {
        group.title = "Settings"
    }

    function test_aliases_resolve() {
        verify(group.backgroundItem)
        verify(group.labelItem)
    }

    function test_title_round_trips() {
        group.title = "Other"
        tryCompare(group.labelItem, "text", "Other")
    }
}
