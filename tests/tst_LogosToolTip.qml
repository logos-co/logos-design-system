import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosToolTip"
    width: 200
    height: 100
    when: windowShown

    // Mid-window anchor: popups can never leave the window, so "above the
    // parent" is only testable when there is room above the parent.
    Item {
        id: midAnchor
        x: 80
        y: 60
        width: 24
        height: 24
    }

    LogosToolTip {
        id: tip
        text: "Hint"
        parent: midAnchor
    }

    function init() {
        tip.text = "Hint"
        tip.placement = LogosToolTip.Top
        tip.delay = 200
    }

    function test_aliases_resolve() {
        verify(tip.backgroundItem)
        verify(tip.labelItem)
        verify(tip.tailItem)
    }

    function test_text_round_trips() {
        tip.text = "Updated"
        tryCompare(tip.labelItem, "text", "Updated")
    }

    function test_default_placement_top() {
        compare(tip.placement, LogosToolTip.Top)
    }

    function test_placement_round_trips() {
        tip.placement = LogosToolTip.Bottom
        compare(tip.placement, LogosToolTip.Bottom)
        tip.placement = LogosToolTip.Left
        compare(tip.placement, LogosToolTip.Left)
        tip.placement = LogosToolTip.Right
        compare(tip.placement, LogosToolTip.Right)
    }

    function test_default_delay_and_timeout() {
        verify(tip.delay > 0)
        verify(tip.timeout > 0)
    }

    function test_tail_rotated_45() {
        compare(tip.tailItem.rotation, 45)
    }

    // Regression: position must not depend on laid-out size (0 on the first
    // open frame), so an instantly-opened tip still floats above its parent.
    function test_top_placement_floats_above_parent_with_no_delay() {
        tip.delay = 0
        tip.open()
        tryCompare(tip, "opened", true)
        verify(tip.y <= -tip.implicitHeight,
               "tip.y (" + tip.y + ") should be above the parent by at least its height")
        tip.close()
        tryCompare(tip, "opened", false)
    }

    function test_height_matches_figma_20() {
        compare(tip.implicitHeight, 20)
        tip.open()
        tryCompare(tip, "opened", true)
        compare(tip.height, 20)
        tip.close()
        tryCompare(tip, "opened", false)
    }
}
