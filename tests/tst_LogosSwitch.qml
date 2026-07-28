import QtQuick
import QtTest

import Logos.Controls
import Logos.Theme

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
        verify(sw.focusRingItem)
    }

    function test_focus_ring_visible_when_keyboard_focused() {
        compare(sw.focusRingItem.border.width, 0)
        sw.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(sw, "visualFocus", true)
        compare(sw.focusRingItem.border.width, 2)
        compare(sw.focusRingItem.border.color, Theme.palette.focus)

        // Still visible when checked (primary track must not hide the ring).
        sw.checked = true
        compare(sw.focusRingItem.border.width, 2)
        compare(sw.focusRingItem.border.color, Theme.palette.focus)
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

    function test_joins_tab_focus_chain() {
        compare(sw.activeFocusOnTab, true)
        compare(sw.focusPolicy, Qt.StrongFocus)
    }

    function test_space_toggles_when_focused() {
        sw.forceActiveFocus()
        tryCompare(sw, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(sw.checked, true)
        compare(clickedSpy.count, 1)
    }
}
