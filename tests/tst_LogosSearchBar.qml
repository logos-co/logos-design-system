import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: root
    name: "LogosSearchBar"
    width: 600
    height: 200
    when: windowShown

    LogosSearchBar {
        id: bar
        placeholderText: "Search..."
    }

    SignalSpy {
        id: submittedSpy
        target: bar
        signalName: "submitted"
    }

    property url defaultIconSource
    Component.onCompleted: defaultIconSource = bar.iconSource

    function init() {
        submittedSpy.clear()
        bar.text = ""
        bar.placeholderText = "Search..."
        bar.shortcutHint = ""
        bar.iconSource = defaultIconSource
        bar.clearable = true
    }

    function test_text_alias_round_trips() {
        bar.text = "hello"
        compare(bar.text, "hello")
        compare(bar.textInput.text, "hello")
    }

    function test_placeholder_default() {
        compare(bar.placeholderText, "Search...")
    }

    function test_iconSource_defaults_to_bundled_search_icon() {
        verify(bar.iconSource.toString().endsWith("icons/search.svg"))
    }

    function test_iconSource_round_trips() {
        bar.iconSource = "qrc:/test-icon.png"
        compare(bar.iconSource.toString(), "qrc:/test-icon.png")
    }

    function test_iconSource_can_be_cleared() {
        bar.iconSource = ""
        compare(bar.iconSource.toString(), "")
    }

    function test_shortcutHint_empty_by_default() {
        compare(bar.shortcutHint, "")
    }

    function test_shortcutHint_round_trips() {
        bar.shortcutHint = "Ctrl+K"
        compare(bar.shortcutHint, "Ctrl+K")
    }

    function test_submitted_emitted_on_textInput_accepted() {
        bar.text = "logos"
        bar.textInput.accepted()
        compare(submittedSpy.count, 1)
        compare(submittedSpy.signalArguments[0][0], "logos")
    }

    function test_inspection_aliases_resolve() {
        verify(bar.fieldItem, "fieldItem must resolve")
        verify(bar.textInput, "textInput must resolve")
        verify(bar.iconItem, "iconItem must resolve")
        verify(bar.clearItem, "clearItem must resolve")
        verify(bar.shortcutItem, "shortcutItem must resolve")
    }

    function test_clearable_defaults_on_and_round_trips() {
        compare(bar.clearable, true)
        bar.clearable = false
        compare(bar.clearable, false)
    }

    function test_clicking_clear_empties_the_field() {
        bar.text = "logos"
        bar.clearItem.clicked()
        compare(bar.text, "")
        compare(bar.textInput.text, "")
    }

    // Clearing is a step in searching, not the end of it — the caret has to
    // stay put so the user can just type again.
    function test_clearing_keeps_focus_in_the_field() {
        bar.text = "logos"
        bar.clearItem.clicked()
        tryCompare(bar.textInput, "activeFocus", true)
    }

    // The button is not a tab stop: it sits between the field and whatever
    // follows, and landing on it on the way out would be a surprise.
    function test_clear_button_is_not_in_the_tab_chain() {
        compare(bar.clearItem.focusPolicy, Qt.NoFocus)
        compare(bar.clearItem.activeFocusOnTab, false)
    }

    function test_textInput_focus_and_select_works_for_consumers() {
        bar.text = "logos"
        bar.textInput.forceActiveFocus()
        bar.textInput.selectAll()
        tryCompare(bar.textInput, "selectedText", "logos")
    }

    function test_joins_tab_focus_chain() {
        compare(bar.activeFocusOnTab, true)
        compare(bar.focusPolicy, Qt.StrongFocus)
    }

    function test_focus_forwards_to_text_input() {
        bar.forceActiveFocus()
        tryCompare(bar.textInput, "activeFocus", true)
    }
}
