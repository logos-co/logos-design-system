import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosSpinBox"
    width: 200
    height: 50
    when: windowShown

    LogosSpinBox {
        id: spin
        from: 0
        to: 10
        value: 3
    }

    function init() {
        spin.value = 3
    }

    function test_aliases_resolve() {
        verify(spin.backgroundItem)
        verify(spin.contentLabel)
    }

    function test_value_round_trips() {
        spin.value = 7
        compare(spin.value, 7)
    }

    function test_increment_decrement() {
        spin.increase()
        compare(spin.value, 4)
        spin.decrease()
        compare(spin.value, 3)
    }

    function test_editable_default() {
        compare(spin.editable, true)
    }

    function test_joins_tab_focus_chain() {
        compare(spin.activeFocusOnTab, true)
        compare(spin.focusPolicy, Qt.StrongFocus)
        compare(spin.contentLabel.activeFocusOnTab, true)
    }
}
