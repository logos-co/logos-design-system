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

    // The indeterminate sweep animates `x` as a property value source. When
    // it stops, x must return to the left edge — otherwise a bar that goes
    // indeterminate and then determinate draws its fill at a stale offset.
    function test_x_returns_to_the_left_edge_after_indeterminate() {
        bar.indeterminate = true
        bar.fillItem.x = 40          // where a sweep would have left it
        bar.indeterminate = false
        bar.value = 0.5
        tryCompare(bar.fillItem, "x", 0, 1000,
                   "determinate fill must start at the left edge")
    }

}
