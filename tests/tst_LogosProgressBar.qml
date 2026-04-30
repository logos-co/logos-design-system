import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosProgressBar"
    width: 300
    height: 50
    when: windowShown

    LogosProgressBar {
        id: bar
        width: 200
        from: 0
        to: 1
        value: 0.5
    }

    function init() {
        bar.value = 0.5
        bar.indeterminate = false
    }

    function test_aliases_resolve() {
        verify(bar.backgroundItem)
        verify(bar.fillItem)
    }

    function test_value_round_trips() {
        bar.value = 0.8
        compare(bar.value, 0.8)
    }

    function test_fill_width_tracks_value() {
        bar.value = 0.5
        var halfWidth = bar.width * 0.5
        tryCompare(bar.fillItem, "width", halfWidth)
    }

    function test_indeterminate_toggle() {
        bar.indeterminate = true
        compare(bar.indeterminate, true)
    }
}
