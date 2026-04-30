import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosToolButton"
    width: 200
    height: 60
    when: windowShown

    LogosToolButton {
        id: btn
        text: "Tool"
    }

    SignalSpy {
        id: clickedSpy
        target: btn
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        btn.text = "Tool"
        btn.enabled = true
    }

    function test_aliases_resolve() {
        verify(btn.labelItem)
        verify(btn.backgroundItem)
    }

    function test_text_round_trips() {
        btn.text = "Action"
        tryCompare(btn.labelItem, "text", "Action")
    }

    function test_clicked_fires() {
        btn.clicked()
        compare(clickedSpy.count, 1)
    }
}
