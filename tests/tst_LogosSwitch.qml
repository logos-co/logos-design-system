import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosSwitch"
    width: 200
    height: 100
    when: windowShown

    LogosSwitch {
        id: sw
        text: "Toggle"
    }

    SignalSpy {
        id: clickedSpy
        target: sw
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        sw.checked = false
        sw.enabled = true
        sw.text = "Toggle"
    }

    function test_aliases_resolve() {
        verify(sw.indicatorItem)
        verify(sw.handleItem)
        verify(sw.labelItem)
    }

    function test_checked_round_trips() {
        sw.checked = true
        compare(sw.checked, true)
    }

    function test_label_text_updates() {
        sw.text = "On"
        tryCompare(sw.labelItem, "text", "On")
    }

    function test_clicked_fires() {
        sw.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_handle_position_updates() {
        sw.checked = true
        tryVerify(function() { return sw.handleItem.x > 2 })
        sw.checked = false
        tryCompare(sw.handleItem, "x", 2)
    }
}
