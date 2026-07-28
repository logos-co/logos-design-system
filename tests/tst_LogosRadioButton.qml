import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
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
        rb.focus = false
        root.forceActiveFocus()
    }

    function test_aliases_resolve() {
        verify(rb.indicatorItem)
        verify(rb.focusRingItem)
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

    function test_focus_ring_visible_when_keyboard_focused() {
        compare(rb.focusRingItem.border.width, 0)
        // Clear any leftover focus so TabFocusReason is applied (forceActiveFocus
        // is a no-op when the item already has activeFocus).
        rb.focus = false
        tryCompare(rb, "activeFocus", false)
        rb.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(rb, "visualFocus", true)
        compare(rb.focusRingItem.border.width, 2)
        compare(rb.focusRingItem.border.color, Theme.palette.focus)

        // Still visible when checked (primary fill must not hide the ring).
        rb.checked = true
        compare(rb.focusRingItem.border.width, 2)
        compare(rb.focusRingItem.border.color, Theme.palette.focus)
    }

    function test_joins_tab_focus_chain() {
        compare(rb.activeFocusOnTab, true)
        compare(rb.focusPolicy, Qt.StrongFocus)
    }

    function test_space_checks_when_focused() {
        rb.forceActiveFocus()
        tryCompare(rb, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(rb.checked, true)
        compare(clickedSpy.count, 1)
    }

    function test_disabled_ignores_keyboard_activate() {
        rb.enabled = false
        rb.forceActiveFocus()
        keyClick(Qt.Key_Space)
        compare(rb.checked, false)
        compare(clickedSpy.count, 0)
    }
}
