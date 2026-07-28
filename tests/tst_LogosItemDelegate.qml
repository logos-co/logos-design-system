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

    function test_joins_tab_focus_chain() {
        compare(item.activeFocusOnTab, true)
        compare(item.focusPolicy, Qt.StrongFocus)
    }

    function test_space_emits_clicked_when_focused() {
        item.forceActiveFocus()
        tryCompare(item, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(clickedSpy.count, 1)
    }
}
