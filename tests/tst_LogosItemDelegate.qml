import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosItemDelegate"
    width: 300
    height: 50
    when: windowShown

    LogosItemDelegate {
        id: item
        text: "Open"
    }

    SignalSpy {
        id: clickedSpy
        target: item
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        item.text = "Open"
        item.enabled = true
    }

    function test_aliases_resolve() {
        verify(item.backgroundItem)
        verify(item.labelItem)
    }

    function test_text_round_trips() {
        item.text = "Save"
        tryCompare(item.labelItem, "text", "Save")
    }

    function test_clicked_fires() {
        item.clicked()
        compare(clickedSpy.count, 1)
    }
}
