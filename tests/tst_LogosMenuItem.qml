import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosMenuItem"
    width: 200
    height: 50
    when: windowShown

    LogosMenuItem {
        id: item
        text: "Action"
    }

    SignalSpy {
        id: triggeredSpy
        target: item
        signalName: "triggered"
    }

    function init() {
        triggeredSpy.clear()
        item.text = "Action"
        item.enabled = true
    }

    function test_aliases_resolve() {
        verify(item.labelItem)
        verify(item.backgroundItem)
    }

    function test_text_round_trips() {
        item.text = "Updated"
        tryCompare(item.labelItem, "text", "Updated")
    }

    function test_triggered_fires() {
        item.triggered()
        compare(triggeredSpy.count, 1)
    }

    function test_joins_tab_focus_chain() {
        compare(item.activeFocusOnTab, true)
        compare(item.focusPolicy, Qt.StrongFocus)
    }
}
