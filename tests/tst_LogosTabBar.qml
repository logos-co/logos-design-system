import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: tc
    name: "LogosTabBar"
    width: 600
    height: 80
    when: windowShown

    LogosTabBar {
        id: bar
        animationDuration: 0
        width: tc.width
        height: 40

        LogosTabButton { text: "One" }
        LogosTabButton { text: "Two" }
        LogosTabButton { text: "Three" }
    }

    function init() {
        bar.indicatorColor = Theme.palette.primary
        bar.indicatorHeight = 3
        bar.currentIndex = 0
    }

    function test_indicator_exists_after_layout() {
        verify(bar.indicatorItem, "indicatorItem alias must resolve")
        verify(bar.indicatorItem.parent, "indicator must have a parent")
    }

    function test_indicator_height_propagates() {
        bar.indicatorHeight = 6
        tryCompare(bar.indicatorItem, "height", 6)
    }

    function test_indicator_color_propagates() {
        bar.indicatorColor = "#123456"
        tryCompare(bar.indicatorItem, "color", "#123456")
    }

    function test_indicator_aligns_with_first_button_at_start() {
        const first = bar.itemAt(0)
        verify(first, "first button must exist")
        if (first.width <= 0) {
            skip("First button width 0 — TabBar's ListView delegate not realized in this environment")
        }
        // Force a refresh: the initial refresh may have run during layout
        // when the button had a transient width.
        bar.indicatorItem.refresh()
        const expectedX = first.mapToItem(bar, 0, 0).x
        tryCompare(bar.indicatorItem, "x", expectedX)
        tryCompare(bar.indicatorItem, "width", first.width)
    }

    function test_indicator_follows_currentIndex_change() {
        bar.currentIndex = 2
        const target = bar.itemAt(2)
        verify(target, "third button must exist")
        if (target.width <= 0) {
            skip("Third button width 0 — TabBar's ListView delegate not realized in this environment")
        }
        bar.indicatorItem.refresh()
        const expectedX = target.mapToItem(bar, 0, 0).x
        tryCompare(bar.indicatorItem, "x", expectedX)
        tryCompare(bar.indicatorItem, "width", target.width)
    }

    function test_indicator_y_pinned_to_bottom() {
        tryCompare(bar.indicatorItem, "y", bar.height - bar.indicatorItem.height)
    }
}
