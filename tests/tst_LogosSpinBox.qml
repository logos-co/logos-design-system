import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
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

    function cleanup() {
        ThemeManager.setDensity("")
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

    // ---- Density and touch ----

    function test_touch_makes_the_box_and_its_buttons_touch_sized() {
        ThemeManager.setDensity("touch")
        compare(spin.implicitHeight, 48)
        compare(spin.up.indicator.width, Theme.size.touchTarget)
        compare(spin.down.indicator.width, Theme.size.touchTarget)
    }

    function test_desktop_box_and_buttons_keep_their_size() {
        compare(spin.implicitHeight, Theme.controls.spinBox.height)
        compare(spin.up.indicator.width, 28)
        compare(spin.down.indicator.width, 28)
    }
}
