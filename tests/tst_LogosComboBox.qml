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
        cbox.popupItem.close()
        tryCompare(cbox.popupItem, "opened", false)
        cbox.maxPopupWidthFactor = 3
        activatedSpy.clear()
        cbox.model = ["alpha", "beta", "gamma"]
        cbox.currentIndex = 0
        cbox.placeholderText = ""
        cbox.textRole = ""
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

    function test_dropdown_widens_to_fit_its_entries() {
        cbox.width = 94
        cbox.model = ["1.0.0", "2.0.0-32.gf8ab37c1 and then some"]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        verify(cbox.popupItem.width > cbox.width,
               "popup " + cbox.popupItem.width + " should outgrow the control " + cbox.width)
        tryVerify(function() { return cbox.popupListView.itemAtIndex(1) !== null })
        compare(cbox.popupListView.itemAtIndex(1).contentItem.truncated, false,
                "the widest entry is not elided")
    }

    // Swapping the model for one with the same number of longer entries still
    // re-measures: nothing here is keyed on the count alone.
    function test_width_tracks_a_replaced_model() {
        cbox.width = 94
        cbox.model = ["1.0.0", "1.0.1"]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        const short_ = cbox.popupItem.width
        cbox.popupItem.close()
        tryCompare(cbox.popupItem, "opened", false)

        cbox.model = ["2.0.0-32.gf8ab37c1", "2.0.0-31.gaa11bb22"]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        tryVerify(function() { return cbox.popupItem.width > short_ }, 2000,
                  "popup stuck at " + short_ + " for the longer model")
    }

    // A row edited in place has no textAt() notification behind it, so the
    // width has to follow the model's dataChanged.
    function test_width_tracks_a_row_edited_in_place() {
        var rows = Qt.createQmlObject(
            'import QtQml.Models; ListModel { ListElement { label: "1.0.0" } }', root)
        cbox.width = 94
        cbox.model = rows
        cbox.textRole = "label"
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        const before = cbox.popupItem.width

        rows.setProperty(0, "label", "2.0.0-32.gf8ab37c1")
        tryVerify(function() { return cbox.popupItem.width > before }, 2000,
                  "popup stuck at " + before + " after the row was edited")
    }

    function test_dropdown_never_narrower_than_the_control() {
        cbox.width = 300
        cbox.model = ["a", "b"]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        compare(cbox.popupItem.width, 300)
    }

    function test_dropdown_width_is_capped() {
        cbox.width = 60
        cbox.maxPopupWidthFactor = 2
        cbox.model = ["x".repeat(200)]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        compare(cbox.popupItem.width, 120, "capped at the factor, not the text")
    }

    function test_space_opens_popup_when_focused() {
        cbox.forceActiveFocus()
        tryCompare(cbox, "activeFocus", true)
        keyClick(Qt.Key_Space)
        tryCompare(cbox.popupItem, "opened", true)
        cbox.popupItem.close()
    }
}
