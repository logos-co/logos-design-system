import QtQuick
import QtTest

import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosMenuItem"
    width: 200
    height: 50
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosMenuItem {
        id: item
        text: "Action"
    }

    SignalSpy {
        id: triggeredSpy
        target: item
        signalName: "triggered"
    }

    function init() {
        triggeredSpy.clear()
        item.text = "Action"
        item.enabled = true
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_aliases_resolve() {
        verify(item.labelItem)
        verify(item.backgroundItem)
    }

    function test_text_round_trips() {
        item.text = "Updated"
        tryCompare(item.labelItem, "text", "Updated")
    }

    function test_triggered_fires() {
        item.triggered()
        compare(triggeredSpy.count, 1)
    }

    function test_joins_tab_focus_chain() {
        compare(item.activeFocusOnTab, true)
        compare(item.focusPolicy, Qt.StrongFocus)
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

    function test_density_scales_height_and_side_padding_data() {
        return [
            { tag: "compact", density: "compact", height: 27, paddingX: 10 },
            { tag: "comfortable", density: "comfortable", height: 32, paddingX: 12 },
            { tag: "touch", density: "touch", height: 44, paddingX: 14 },
        ]
    }

    function test_density_scales_height_and_side_padding(data) {
        ThemeManager.setDensity(data.density)
        compare(item.implicitHeight, data.height)
        compare(item.labelItem.leftPadding, data.paddingX)
        compare(item.labelItem.rightPadding, data.paddingX)
    }

    Component {
        id: withTooltip
        LogosMenuItem {
            text: "Item"
            width: 200
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosMenuItem { text: "Item"; width: 200 }
    }

    // At touch density a long-press shows the tooltip instead of doing the
    // action; a tap still does it.
    function test_touch_long_press_opens_the_tooltip_instead_of_clicking() {
        ThemeManager.setDensity("touch")
        const c = createRendered(withTooltip)
        const spy = spyFor(c, "clicked")
        holdOn(c)
        tryCompare(c.tip, "opened", true)
        compare(spy.count, 0)
        mouseClick(c)
        compare(spy.count, 1)
    }

    // Without a tooltip a long-press is a click, so a slow press still works.
    function test_touch_long_press_without_a_tooltip_clicks() {
        ThemeManager.setDensity("touch")
        const c = createRendered(withoutTooltip)
        const spy = spyFor(c, "clicked")
        holdOn(c)
        compare(spy.count, 1)
    }

    function test_desktop_long_press_clicks() {
        const c = createRendered(withTooltip)
        const spy = spyFor(c, "clicked")
        holdOn(c)
        compare(spy.count, 1)
        verify(!c.tip.opened)
    }
}
