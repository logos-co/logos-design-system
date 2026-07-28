import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    name: "LogosSelectableText"
    width: 400
    height: 200
    when: windowShown

    LogosSelectableText {
        id: selectable
        text: "QmAbc123"
        width: 200
        height: 24
    }

    function init() {
        selectable.text = "QmAbc123"
        selectable.color = Theme.palette.text
        selectable.selectByMouse = true
        selectable.wrapMode = TextEdit.NoWrap
        selectable.deselect()
    }

    function test_text_round_trips() {
        compare(selectable.text, "QmAbc123")
        selectable.text = "other"
        compare(selectable.text, "other")
    }

    function test_readOnly_is_true() {
        compare(selectable.readOnly, true)
    }

    function test_textFormat_is_plain() {
        compare(selectable.textFormat, TextEdit.PlainText)
    }

    function test_selectByMouse_default_true() {
        compare(selectable.selectByMouse, true)
    }

    function test_default_font_matches_theme() {
        compare(selectable.font.family, Theme.typography.publicSans)
        compare(selectable.font.pixelSize, Theme.typography.primaryText)
        compare(selectable.font.weight, Theme.typography.weightRegular)
    }

    function test_default_color_is_theme_text() {
        tryCompare(selectable, "color", Theme.palette.text)
    }

    function test_color_can_be_overridden() {
        selectable.color = Theme.palette.textSecondary
        tryCompare(selectable, "color", Theme.palette.textSecondary)
    }

    function test_selectAll_fills_selectedText() {
        selectable.selectAll()
        compare(selectable.selectedText, "QmAbc123")
    }

    function test_deselect_clears_selectedText() {
        selectable.selectAll()
        compare(selectable.selectedText, "QmAbc123")
        selectable.deselect()
        compare(selectable.selectedText, "")
    }
}
