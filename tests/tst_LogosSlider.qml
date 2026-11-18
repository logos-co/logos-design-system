import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosSlider"
    width: 300
    height: 50
    when: windowShown

    LogosSlider {
        id: slider
        width: 200
        from: 0
        to: 100
        value: 50
    }

    function init() {
        slider.value = 50
    }

    function cleanup() {
        ThemeManager.setDensity("")
    }

    function test_aliases_resolve() {
        verify(slider.trackItem)
        verify(slider.fillItem)
        verify(slider.handleItem)
    }

    function test_value_round_trips() {
        slider.value = 75
        compare(slider.value, 75)
    }

    function test_visualPosition_tracks_value() {
        slider.value = 100
        compare(slider.visualPosition, 1.0)
        slider.value = 0
        compare(slider.visualPosition, 0.0)
    }

    function test_joins_tab_focus_chain() {
        compare(slider.activeFocusOnTab, true)
        compare(slider.focusPolicy, Qt.StrongFocus)
    }

    // ---- Density and touch ----

    function test_touch_row_is_touch_tall_and_the_track_keeps_its_size() {
        ThemeManager.setDensity("touch")
        verify(slider.implicitHeight >= Theme.size.touchTarget)
        compare(slider.trackItem.height, Theme.controls.slider.trackHeight)
        compare(slider.handleItem.width, Theme.controls.slider.handleSize)
    }

    function test_desktop_row_hugs_the_handle() {
        verify(slider.implicitHeight < Theme.size.touchTarget)
    }
}
