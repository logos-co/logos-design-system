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
        verify(bar.shortcutItem, "shortcutItem must resolve")
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
