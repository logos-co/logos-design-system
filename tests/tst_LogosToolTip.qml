import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosToolTip"
    width: 200
    height: 100
    when: windowShown

    LogosToolTip {
        id: tip
        text: "Hint"
    }

    function init() {
        tip.text = "Hint"
        tip.placement = LogosToolTip.Top
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

    function test_height_matches_figma_20() {
        compare(tip.implicitHeight, 20)
        tip.open()
        tryCompare(tip, "opened", true)
        compare(tip.height, 20)
        tip.close()
        tryCompare(tip, "opened", false)
    }
}
