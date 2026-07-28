import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: root
    name: "LogosComboBox"
    width: 400
    height: 200
    when: windowShown

    LogosComboBox {
        id: cbox
        model: ["alpha", "beta", "gamma"]
    }

    SignalSpy {
        id: activatedSpy
        target: cbox
        signalName: "activated"
    }

    function init() {
        activatedSpy.clear()
        cbox.model = ["alpha", "beta", "gamma"]
        cbox.currentIndex = 0
        cbox.placeholderText = ""
        cbox.enabled = true
    }

    function test_model_round_trips() {
        cbox.model = ["x", "y"]
        compare(cbox.count, 2)
        compare(cbox.textAt(0), "x")
        compare(cbox.textAt(1), "y")
    }

    function test_currentIndex_round_trips() {
        cbox.currentIndex = 2
        compare(cbox.currentIndex, 2)
        compare(cbox.currentText, "gamma")
    }

    function test_currentText_reflects_selection() {
        cbox.currentIndex = 1
        tryCompare(cbox, "currentText", "beta")
    }

    function test_displayText_falls_through_to_currentText() {
        cbox.currentIndex = 0
        tryCompare(cbox, "displayText", "alpha")
    }

    function test_activated_signal_emits_with_index() {
        cbox.activated(2)
        compare(activatedSpy.count, 1)
        compare(activatedSpy.signalArguments[0][0], 2)
    }

    function test_placeholderText_round_trips() {
        cbox.placeholderText = "Pick one..."
        compare(cbox.placeholderText, "Pick one...")
    }

    function test_placeholder_shown_when_displayText_empty() {
        // Empty model → empty displayText → contentLabel renders placeholder.
        cbox.model = []
        cbox.placeholderText = "Choose"
        tryCompare(cbox.contentLabel, "text", "Choose")
    }

    function test_inspection_aliases_resolve() {
        verify(cbox.contentLabel, "contentLabel must resolve")
        verify(cbox.backgroundItem, "backgroundItem must resolve")
        verify(cbox.popupItem, "popupItem must resolve")
    }

    function test_disabled_changes_text_color() {
        cbox.enabled = true
        const enabledColor = cbox.contentLabel.color.toString()
        cbox.enabled = false
        const disabledColor = cbox.contentLabel.color.toString()
        verify(enabledColor !== disabledColor,
               "contentLabel.color should differ between enabled and disabled states")
    }

    function test_textRole_picks_from_object_model() {
        cbox.model = [{ label: "one" }, { label: "two" }]
        cbox.textRole = "label"
        cbox.currentIndex = 0
        tryCompare(cbox, "currentText", "one")
        cbox.currentIndex = 1
        tryCompare(cbox, "currentText", "two")
    }

    function test_joins_tab_focus_chain() {
        compare(cbox.activeFocusOnTab, true)
        compare(cbox.focusPolicy, Qt.StrongFocus)
    }

    function test_space_opens_popup_when_focused() {
        cbox.forceActiveFocus()
        tryCompare(cbox, "activeFocus", true)
        keyClick(Qt.Key_Space)
        tryCompare(cbox.popupItem, "opened", true)
        cbox.popupItem.close()
    }
}
