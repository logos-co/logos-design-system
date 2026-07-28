import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosCheckbox"
    width: 400
    height: 200
    when: windowShown

    LogosCheckbox {
        id: cbox
        text: "Accept"
    }

    SignalSpy {
        id: clickedSpy
        target: cbox
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        cbox.checked = false
        cbox.enabled = true
        cbox.text = "Accept"
        cbox.focus = false
    }

    function test_renders_text() {
        compare(cbox.text, "Accept")
    }

    function test_text_setter_updates_label() {
        cbox.text = "Updated"
        tryCompare(cbox.labelItem, "text", "Updated")
    }

    function test_checked_property_round_trips() {
        cbox.checked = true
        compare(cbox.checked, true)
        cbox.checked = false
        compare(cbox.checked, false)
    }

    function test_emits_clicked_when_invoked() {
        cbox.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_indicator_alias_resolves() {
        verify(cbox.indicatorItem, "indicatorItem alias must resolve")
        verify(cbox.focusRingItem, "focusRingItem alias must resolve")
    }

    function test_label_alias_resolves() {
        verify(cbox.labelItem, "labelItem alias must resolve")
    }

    function test_focus_ring_visible_when_keyboard_focused() {
        compare(cbox.focusRingItem.border.width, 0)
        // Clear any leftover focus so TabFocusReason is applied (forceActiveFocus
        // is a no-op when the item already has activeFocus).
        cbox.focus = false
        tryCompare(cbox, "activeFocus", false)
        cbox.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(cbox, "visualFocus", true)
        compare(cbox.focusRingItem.border.width, 2)
        compare(cbox.focusRingItem.border.color, Theme.palette.focus)

        // Still visible when checked (primary fill must not hide the ring).
        cbox.checked = true
        compare(cbox.focusRingItem.border.width, 2)
        compare(cbox.focusRingItem.border.color, Theme.palette.focus)
    }

    function test_label_color_switches_with_enabled() {
        cbox.enabled = true
        tryCompare(cbox.labelItem, "color", Theme.palette.text)
        cbox.enabled = false
        tryCompare(cbox.labelItem, "color", Theme.palette.textMuted)
    }

    function test_joins_tab_focus_chain() {
        compare(cbox.activeFocusOnTab, true)
        compare(cbox.focusPolicy, Qt.StrongFocus)
    }

    function test_space_toggles_when_focused() {
        cbox.forceActiveFocus()
        tryCompare(cbox, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(cbox.checked, true)
        compare(clickedSpy.count, 1)
    }

    function test_disabled_ignores_keyboard_activate() {
        cbox.enabled = false
        cbox.forceActiveFocus()
        keyClick(Qt.Key_Space)
        compare(cbox.checked, false)
        compare(clickedSpy.count, 0)
    }
}
