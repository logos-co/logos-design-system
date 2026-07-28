import QtQuick
import QtTest

import Logos.Controls

// Mirrors the storybook LogosToolTipPage pattern: tooltips declared inside a
// Repeater delegate with an implicit parent, placement fed from a model that
// uses LogosToolTip.* enum references, shown by binding `visible`.
TestCase {
    id: testCase
    name: "LogosToolTipPlacements"
    width: 400
    height: 300
    when: windowShown

    property bool showTips: false

    Repeater {
        id: cells
        model: [
            { label: "Top",    placement: LogosToolTip.Top },
            { label: "Bottom", placement: LogosToolTip.Bottom },
            { label: "Left",   placement: LogosToolTip.Left },
            { label: "Right",  placement: LogosToolTip.Right }
        ]

        delegate: Item {
            required property var modelData
            required property int index
            // Mid-window anchors, spread out so tips never clamp.
            x: 120 + (index % 2) * 140
            y: 100 + Math.floor(index / 2) * 100
            width: 24
            height: 24

            readonly property alias tip: theTip

            LogosToolTip {
                id: theTip
                text: modelData.label
                placement: modelData.placement
                delay: 0
                visible: testCase.showTips
            }
        }
    }

    function init() {
        showTips = false
    }

    // Placement values are aligned with Popup.TransformOrigin because the
    // names collide with that inherited C++ enum and QML may resolve
    // LogosToolTip.Top to either — alignment makes both paths identical.
    function test_enum_values_in_consumer_scope() {
        compare(LogosToolTip.Top, 1)
        compare(LogosToolTip.Left, 3)
        compare(LogosToolTip.Right, 5)
        compare(LogosToolTip.Bottom, 7)
    }

    function test_all_placements_render_on_stated_side() {
        showTips = true
        for (var i = 0; i < cells.count; i++) {
            var cell = cells.itemAt(i)
            var tip = cell.tip
            tryCompare(tip, "opened", true)
            switch (cell.modelData.label) {
            case "Top":
                verify(tip.y < 0, "Top tip should be above its parent, y = " + tip.y)
                break
            case "Bottom":
                verify(tip.y >= cell.height, "Bottom tip should be below its parent, y = " + tip.y)
                break
            case "Left":
                verify(tip.x < 0, "Left tip should be left of its parent, x = " + tip.x)
                break
            case "Right":
                verify(tip.x >= cell.width, "Right tip should be right of its parent, x = " + tip.x)
                break
            }
        }
        showTips = false
    }
}
