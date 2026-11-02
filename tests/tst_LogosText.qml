import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosText"
    width: 200
    height: 100
    when: windowShown

    LogosText {
        id: txt
        text: "Hello"
    }

    function test_renders_text() {
        compare(txt.text, "Hello")
    }

    function test_default_color_matches_theme() {
        compare(txt.color.toString(), Theme.palette.text.toString())
    }

    function test_default_pixelSize_matches_theme_primary() {
        compare(txt.font.pixelSize, Theme.typography.primaryText)
    }

    function test_default_weight_is_regular() {
        compare(txt.font.weight, Theme.typography.weightRegular)
    }

    LogosText { id: markup; text: "<b>Bold</b>" }
    LogosText { id: plainMarkupText; text: "<b>Bold</b>"; textFormat: Text.PlainText; font: markup.font }
    LogosText { id: styled; text: "<b>Bold</b>"; textFormat: Text.StyledText }

    // Text that looks like HTML is shown as written unless the caller opts in:
    // a name from outside the app cannot restyle itself.
    function test_markup_is_shown_as_written_by_default() {
        compare(markup.textFormat, Text.PlainText)
        compare(markup.implicitWidth, plainMarkupText.implicitWidth)
        verify(styled.implicitWidth < markup.implicitWidth, "StyledText renders the tags away")
    }
}
