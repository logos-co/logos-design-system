import QtQuick
import QtTest

import Logos.Controls

TestCase {
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
}
