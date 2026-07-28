import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosTextArea"
    width: 300
    height: 200
    when: windowShown

    LogosTextArea {
        id: area
        text: "hello"
    }

    function init() {
        area.text = "hello"
        area.enabled = true
    }

    function test_text_round_trips() {
        area.text = "world"
        compare(area.text, "world")
    }

    function test_alias_resolves() {
        verify(area.backgroundItem)
    }

    function test_wraps_by_default() {
        compare(area.wrapMode, TextEdit.Wrap)
    }

    function test_select_by_mouse() {
        compare(area.selectByMouse, true)
    }

    function test_joins_tab_focus_chain() {
        compare(area.activeFocusOnTab, true)
        compare(area.focusPolicy, Qt.StrongFocus)
    }
}
