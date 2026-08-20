import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosTabBar"
    width: 600
    height: 80
    when: windowShown

    LogosTabBar {
        id: bar
        animationDuration: 0
        width: root.width
        height: 40

        LogosTabButton { text: "One" }
        LogosTabButton { text: "Two" }
        LogosTabButton { text: "Three" }
    }

    // Reproduces the wallet's exact nesting: a StackLayout whose second page is an
    // Item wrapping an anchors-filled ColumnLayout that holds the bar. The bar is
    // therefore laid out while its page is not current.
    Item {
        id: host
        width: root.width
        height: 120

        ColumnLayout {
            anchors.fill: parent

            LogosTabBar {
                id: outerBar
                Layout.fillWidth: true
                animationDuration: 0
                LogosTabButton { text: "Transfer" }
                LogosTabButton { text: "Bridge" }
            }

            StackLayout {
                id: pages
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: outerBar.currentIndex

                Item {}

                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        LogosTabBar {
                            id: nestedBar
                            Layout.fillWidth: true
                            animationDuration: 0
                            spacing: 8
                            LogosTabButton { text: "Withdraw" }
                            LogosTabButton { text: "Claim Deposit" }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }

    function init() {
        bar.indicatorColor = Theme.palette.primary
        bar.indicatorHeight = 3
        bar.trackColor = Theme.palette.borderHairline
        bar.currentIndex = 0
    }

    function test_indicator_exists_after_layout() {
        verify(bar.indicatorItem, "indicatorItem alias must resolve")
        verify(bar.indicatorItem.parent, "indicator must have a parent")
    }

    function test_track_exists() {
        verify(bar.trackItem, "trackItem alias must resolve")
        compare(bar.trackItem.color, Theme.palette.borderHairline)
    }

    function test_track_color_propagates() {
        bar.trackColor = "#abcdef"
        tryCompare(bar.trackItem, "color", "#abcdef")
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

    // The indicator must never paint outside the bar. Before the background was
    // clipped and refresh() learned to skip un-laid-out items, a bar revealed for
    // the first time kept a position measured at zero width -- drawing the line
    // beside the bar, over whatever sat next to it, rather than under a tab.
    function test_indicator_lands_under_the_tab_when_a_nested_page_is_revealed() {
        outerBar.currentIndex = 0
        wait(50)
        outerBar.currentIndex = 1          // reveal the page holding nestedBar
        tryVerify(function() { return nestedBar.width > 0 }, 2000)
        wait(100)

        const ind = nestedBar.indicatorItem
        const btn = nestedBar.itemAt(nestedBar.currentIndex)
        verify(btn, "no current tab button")

        verify(ind.width > 0, "indicator has no width -- it was never placed")
        fuzzyCompare(ind.x, btn.mapToItem(nestedBar, 0, 0).x, 1.0)
        fuzzyCompare(ind.width, btn.width, 1.0)
    }
}
