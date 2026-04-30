import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosRadioButton"
    width: 200
    height: 100
    when: windowShown

    LogosRadioButton {
        id: rb
        text: "Pick me"
    }

    SignalSpy {
        id: clickedSpy
        target: rb
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        rb.checked = false
        rb.enabled = true
        rb.text = "Pick me"
    }

    function test_aliases_resolve() {
        verify(rb.indicatorItem)
        verify(rb.labelItem)
    }

    function test_checked_round_trips() {
        rb.checked = true
        compare(rb.checked, true)
    }

    function test_label_text_updates() {
        rb.text = "Selected"
        tryCompare(rb.labelItem, "text", "Selected")
    }

    function test_clicked_fires() {
        rb.clicked()
        compare(clickedSpy.count, 1)
    }
}
