import QtQuick
import QtQuick.Controls
import QtQuick.Window
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

    function singleRowModel(label) {
        return Qt.createQmlObject(
            'import QtQml.Models; ListModel { ListElement { label: "' + label + '" } }', root)
    }

    function init() {
        cbox.popupItem.close()
        tryCompare(cbox.popupItem, "opened", false)
        cbox.x = 0
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
        var rows = singleRowModel("1.0.0")
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

    // The row's label has the same missing notifier as the width: widening the
    // dropdown around text it never repaints helps nobody.
    function test_entry_text_follows_a_row_edited_in_place() {
        var rows = singleRowModel("1.0.0")
        cbox.model = rows
        cbox.textRole = "label"
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        tryVerify(function() { return cbox.popupListView.itemAtIndex(0) !== null })

        rows.setProperty(0, "label", "2.0.0-32.gf8ab37c1")
        tryCompare(cbox.popupListView.itemAtIndex(0).contentItem, "text", "2.0.0-32.gf8ab37c1")
    }

    // A row is sized by a hidden copy of itself rather than by the font's own
    // metrics, because the two disagree by a whole hinted step per glyph on
    // some builds. A string of the widest glyph there is makes that gap large
    // enough to elide.
    function test_widest_entry_is_not_elided_when_it_ends_in_a_wide_glyph() {
        cbox.width = 94
        cbox.model = ["1.0.0", "WWWWWWWWWWWWWWWWWWWW"]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        tryVerify(function() { return cbox.popupListView.itemAtIndex(1) !== null })
        verify(cbox.popupItem.width < cbox.width * cbox.maxPopupWidthFactor,
               "entry must fit under the cap for this to test the measurement")

        // The numbers, not only the verdict: a width that came from the wrong
        // measurement says so here, and nowhere else.
        const entry = cbox.popupListView.itemAtIndex(1).contentItem
        verify(entry.width >= entry.implicitWidth,
               "row was given " + entry.width + "px for text that lays out at "
               + entry.implicitWidth + "px")
        compare(entry.truncated, false, "the widest entry is elided")
    }

    // Which entry is widest is itself a measurement. Every row is checked, so
    // the test does not have to agree with the component about which one wins.
    function test_no_entry_is_elided_below_the_cap() {
        cbox.width = 94
        cbox.model = ["1.0.0", "WWW WWW", "MMMMMMMMMM", "gjpqy_|,."]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        tryVerify(function() {
            return cbox.popupListView.itemAtIndex(cbox.count - 1) !== null
        }, 2000, "the dropdown never laid out all " + cbox.count + " rows")
        verify(cbox.popupItem.width < cbox.width * cbox.maxPopupWidthFactor,
               "entries must fit under the cap for this to test the measurement")

        for (var i = 0; i < cbox.count; ++i) {
            const row = cbox.popupListView.itemAtIndex(i).contentItem
            verify(row.width >= row.implicitWidth,
                   "row " + i + " was given " + row.width
                   + "px for text that lays out at " + row.implicitWidth + "px")
        }
    }

    // A dropdown that outgrows its control runs off the window when the
    // control sits by the right edge.
    function test_dropdown_stays_inside_the_window() {
        const win = root.Window.window
        verify(win, "no window to clamp against")
        cbox.width = 100
        cbox.x = win.width - cbox.width - 4
        cbox.model = ["1.0.0", "2.0.0-32.gf8ab37c1 (nightly) build 2026-09-22"]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)

        const popup = cbox.popupItem
        // Where the popup landed, not where its x asked to be.
        const sceneX = popup.contentItem.mapToItem(null, 0, 0).x - popup.leftPadding
        verify(sceneX + popup.width <= win.width,
               "popup right edge " + (sceneX + popup.width) + " is past the window " + win.width)
    }

    // maxPopupWidthFactor is measured against the control, so a wide control
    // in a narrow window can ask for more width than there is. Popup only
    // repositions an explicitly sized popup — it will not shrink one.
    function test_dropdown_width_is_capped_to_the_window() {
        const win = root.Window.window
        verify(win, "no window to cap against")
        cbox.width = 200
        cbox.model = ["1.0.0", "x".repeat(120)]
        verify(cbox.width * cbox.maxPopupWidthFactor > win.width,
               "the factor must allow more than the window for this to test the cap")
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        verify(cbox.popupItem.width <= win.width,
               "popup " + cbox.popupItem.width + " is wider than the window " + win.width)
    }

    // The popup's own padding has to be in its implicit height, or a dropdown
    // is short of its rows and scrolls with nowhere to go.
    function test_dropdown_is_as_tall_as_its_rows() {
        cbox.model = ["a", "b", "c"]
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        tryVerify(function() { return cbox.popupListView.contentHeight > 0 })
        verify(cbox.popupListView.contentHeight <= cbox.popupListView.height,
               "rows " + cbox.popupListView.contentHeight
               + " don't fit the list " + cbox.popupListView.height)
    }

    // A model long enough to outgrow the screen stops at the window and
    // scrolls, the way Qt's own ComboBox caps its dropdown.
    function test_dropdown_height_is_capped_to_the_window() {
        const win = root.Window.window
        verify(win, "no window to cap against")
        cbox.model = Array.from({length: 200}, function(_, i) { return "entry " + i })
        cbox.popupItem.open()
        tryCompare(cbox.popupItem, "opened", true)
        verify(cbox.popupItem.height <= win.height,
               "popup " + cbox.popupItem.height + " is taller than the window " + win.height)
        verify(cbox.popupListView.contentHeight > cbox.popupListView.height,
               "the capped list should scroll")
        verify(cbox.popupListView.ScrollBar.vertical,
               "a capped dropdown needs a scroll bar to say so")
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
