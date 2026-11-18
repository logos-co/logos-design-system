import QtQuick
import QtTest

import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosToolTip"
    width: 200
    height: 100
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
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

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
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

    // Plain like LogosText: a tip often repeats text from outside the app.
    function test_text_is_plain_unless_opted_in() {
        compare(tip.textFormat, Text.PlainText)
        compare(tip.labelItem.textFormat, Text.PlainText)
        tip.textFormat = Text.StyledText
        compare(tip.labelItem.textFormat, Text.StyledText)
        tip.textFormat = Text.PlainText
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

    // Separate fixture — a tooltip that sets manualX/manualY. Presence of
    // those values (not `undefined`) opts out of placement-based positioning
    // and pins the tip at the consumer's coordinates.
    LogosToolTip {
        id: manualTip
        parent: midAnchor
        text: "Manual"
        placement: LogosToolTip.Right
        delay: 0
        manualX: 42
        manualY: 7
    }

    function test_manual_x_and_y_default_undefined() {
        // Auto mode is the default: consumers that don't set manualX/manualY
        // get placement-based positioning. `tip` (fixture without manual*)
        // must have both undefined.
        compare(tip.manualX, undefined)
        compare(tip.manualY, undefined)
    }

    function test_manual_position_honored_when_set() {
        manualTip.open()
        tryCompare(manualTip, "opened", true)
        // Popup's C++ layout writes x/y on open; the Binding on manualX/
        // manualY reasserts. tryCompare so the write settles.
        tryCompare(manualTip, "x", 42)
        tryCompare(manualTip, "y", 7)
        manualTip.close()
        tryCompare(manualTip, "opened", false)
    }


    // ---- Density and touch ----

    Component { id: longPressSpy; SignalSpy {} }

    // Input reaches a new item once it has been rendered.
    function createRendered(component, properties) {
        const item = createTemporaryObject(component, root, properties || {})
        waitForRendering(item)
        return item
    }

    function holdOn(item) {
        mousePress(item)
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        mouseRelease(item)
    }

    function spyFor(target, signalName) {
        return createTemporaryObject(longPressSpy, root, { target: target, signalName: signalName })
    }

    Component {
        id: labelWithTip
        LogosText {
            text: "A long name"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "A long name, in full" }
        }
    }
    Component {
        id: labelWithLongPressOff
        LogosText {
            text: "A long name"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip"; openOnLongPress: false }
        }
    }
    Component {
        id: labelWithEmptyTip
        LogosText {
            text: "A name"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "" }
        }
    }
    Component {
        id: buttonWithLongPressOff
        LogosIconButton {
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip"; openOnLongPress: false }
        }
    }

    function test_open_on_long_press_by_default() {
        compare(tip.openOnLongPress, true)
    }

    // On something that isn't a button, e.g. a cut-off label.
    function test_touch_long_press_opens_and_a_tap_closes() {
        ThemeManager.setDensity("touch")
        const l = createRendered(labelWithTip)
        holdOn(l)
        tryCompare(l.tip, "opened", true)
        mouseClick(l)
        tryCompare(l.tip, "opened", false)
    }

    function test_desktop_long_press_does_nothing() {
        const l = createRendered(labelWithTip)
        holdOn(l)
        wait(400)
        verify(!l.tip.opened)
    }

    function test_touch_long_press_respects_open_on_long_press_off() {
        ThemeManager.setDensity("touch")
        const l = createRendered(labelWithLongPressOff)
        holdOn(l)
        wait(400)
        verify(!l.tip.opened)
    }

    function test_touch_long_press_does_not_open_an_empty_tip() {
        ThemeManager.setDensity("touch")
        const l = createRendered(labelWithEmptyTip)
        holdOn(l)
        wait(400)
        verify(!l.tip.opened)
    }

    // A tip that doesn't open on long-press doesn't take the click either.
    function test_touch_tip_with_long_press_off_does_not_swallow_the_click() {
        ThemeManager.setDensity("touch")
        const b = createRendered(buttonWithLongPressOff)
        const clicked = spyFor(b, "clicked")
        holdOn(b)
        compare(clicked.count, 1)
        verify(!b.tip.opened)
    }
}
