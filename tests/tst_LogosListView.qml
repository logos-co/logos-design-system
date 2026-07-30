import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Controls

TestCase {
    name: "LogosListView"
    width: 400
    height: 320
    when: windowShown

    // Overflowing fixture — 30 rows in a viewport that fits ~5, so the
    // attached scroll bar has something to show.
    LogosListView {
        id: overflowing
        x: 0; y: 0
        width: 150; height: 150
        model: 30
        delegate: Rectangle {
            width: ListView.view.width
            height: 30
            color: "transparent"
        }
    }

    // Fits-in-viewport fixture — three short rows, no overflow.
    LogosListView {
        id: fitting
        x: 160; y: 0
        width: 150; height: 150
        model: 3
        delegate: Rectangle {
            width: ListView.view.width
            height: 20
            color: "transparent"
        }
    }

    // Header fixture — exercises the built-in ListView `header:` slot.
    LogosListView {
        id: withHeader
        x: 0; y: 160
        width: 150; height: 150
        model: 4
        header: Rectangle {
            objectName: "hdr"
            width: ListView.view.width
            height: 24
            color: "transparent"
        }
        delegate: Rectangle {
            width: ListView.view.width
            height: 20
            color: "transparent"
        }
    }

    function test_is_a_listview() {
        // Sanity: LogosListView IS a ListView — the model/delegate API
        // downstream authors expect is unchanged.
        compare(overflowing.count, 30)
        compare(fitting.count, 3)
    }

    function test_defaults_baked_in() {
        // The whole point of the wrapper — consumers shouldn't have to set
        // these per call site.
        compare(overflowing.clip, true)
        compare(overflowing.boundsBehavior, Flickable.StopAtBounds)
        verify(overflowing.spacing >= 0)
    }

    function test_scroll_bar_attached_with_4px_inset() {
        // Design-system rule: vertical scroll bar sits 4 px left of the list's
        // right border, so it doesn't overlap the content it's tracking. The
        // knob is `rightPadding` on the LogosScrollBar (attached-bar layout
        // ignores anchor margins).
        const bar = overflowing.ScrollBar.vertical
        verify(bar)
        compare(bar.rightPadding, 4)
    }

    function test_scroll_bar_reports_no_overflow_when_fitting() {
        // ScrollBar.size = fraction of content visible in the viewport.
        // Reaches 1.0 (or greater) exactly when the content fits — that's
        // what the AsNeeded policy uses to decide whether to render.
        const bar = fitting.ScrollBar.vertical
        verify(bar)
        tryCompare(bar, "size", 1.0)
    }

    function test_scroll_bar_reports_overflow_when_overflowing() {
        const bar = overflowing.ScrollBar.vertical
        verify(bar)
        tryVerify(function() { return bar.size > 0 && bar.size < 1.0 })
    }

    function test_header_slot_populates() {
        verify(withHeader.headerItem)
        compare(withHeader.headerItem.objectName, "hdr")
        compare(withHeader.headerItem.height, 24)
    }

    function test_current_index_bindable() {
        compare(overflowing.currentIndex, 0)
        overflowing.currentIndex = 5
        compare(overflowing.currentIndex, 5)
    }

    function test_flickable_scrolling_works() {
        // Programmatic scroll — sanity check that LogosListView really is a
        // Flickable and the built-in scroll bar isn't interfering with the
        // underlying contentY.
        overflowing.contentY = 0
        compare(overflowing.contentY, 0)
        overflowing.contentY = 60
        compare(overflowing.contentY, 60)
    }
}
