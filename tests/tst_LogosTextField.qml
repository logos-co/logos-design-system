import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosTextField"
    width: 400
    height: 200
    when: windowShown

    LogosTextField {
        id: field
        placeholderText: "Enter text"
        anchors.centerIn: parent
        width: 200
    }

    IntValidator {
        id: rangeValidator
        bottom: 10
        top: 100
    }

    function init() {
        field.text = ""
        field.placeholderText = "Enter text"
        field.echoMode = TextInput.Normal
        field.validator = null
        field.readOnly = false
        // QtTest runs alphabetically; take focus back so a focus test does not
        // leak a focused border into later ones.
        root.forceActiveFocus()
    }

    function cleanup() {
        ThemeManager.setDensity("")
    }

    // A placeholder longer than the field ends in "…", not cut mid-letter.
    function test_long_placeholder_ends_in_an_ellipsis() {
        field.placeholderText = "https://example.com/a/long/path/to/its/logos-repo.json"
        verify(field.placeholderItem.truncated)
        field.placeholderText = "Enter text"
        verify(!field.placeholderItem.truncated)
    }

    function test_text_alias_get_set() {
        field.text = "hello"
        compare(field.text, "hello")
        compare(field.textInput.text, "hello")
    }

    function test_input_empty_when_text_cleared() {
        field.text = ""
        compare(field.textInput.text, "")
        compare(field.textInput.text.length, 0)
    }

    function test_input_holds_value_when_text_set() {
        field.text = "x"
        compare(field.textInput.text, "x")
        compare(field.textInput.text.length, 1)
    }

    function test_echo_mode_propagates_to_text_input() {
        field.echoMode = TextInput.Password
        compare(field.textInput.echoMode, TextInput.Password)
    }

    function test_normal_text_color_without_validator() {
        tryCompare(field.textInput, "color", Theme.palette.text)
    }

    function test_normal_border_when_empty_with_validator() {
        field.validator = rangeValidator
        field.text = ""
        tryCompare(field.backgroundItem.border, "color", Theme.palette.backgroundElevated)
    }

    function test_error_border_when_input_not_acceptable() {
        field.validator = rangeValidator
        field.text = "5"
        tryCompare(field.backgroundItem.border, "color", Theme.palette.error)
    }
    function test_error_text_color_when_input_not_acceptable() {
        field.validator = rangeValidator
        field.text = "5"
        tryCompare(field.textInput, "color", Theme.palette.error)
    }

    function test_normal_text_color_when_input_acceptable() {
        field.validator = rangeValidator
        field.text = "50"
        tryCompare(field.textInput, "color", Theme.palette.text)
    }

    function test_read_only_propagates_to_text_input() {
        field.readOnly = true
        compare(field.textInput.readOnly, true)
    }

    function test_focus_reaches_the_editor() {
        field.forceActiveFocus()
        tryCompare(field.textInput, "activeFocus", true)
    }

    function test_joins_tab_focus_chain() {
        compare(field.activeFocusOnTab, true)
        compare(field.focusPolicy, Qt.StrongFocus)
        compare(field.textInput.activeFocusOnTab, true)
    }

    function test_input_uses_theme_font_family() {
        // The TextInput set no family, so it rendered in the system sans
        // instead of Public Sans.
        compare(field.textInput.font.family, Theme.typography.publicSans)
    }

    // ---- Density and touch ----

    function test_density_scales_height_and_side_padding_data() {
        return [
            { tag: "compact", density: "compact", height: 34, paddingX: 10 },
            { tag: "comfortable", density: "comfortable", height: 40, paddingX: 12 },
            { tag: "touch", density: "touch", height: 48, paddingX: 14 },
        ]
    }

    function test_density_scales_height_and_side_padding(data) {
        ThemeManager.setDensity(data.density)
        compare(field.implicitHeight, data.height)
        compare(field.leftPadding, data.paddingX)
        compare(field.rightPadding, data.paddingX)
    }
}
