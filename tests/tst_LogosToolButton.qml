import QtQuick
import QtTest

import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosToolButton"
    width: 200
    height: 60
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosToolButton {
        id: btn
        text: "Tool"
    }

    SignalSpy {
        id: clickedSpy
        target: btn
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        btn.text = "Tool"
        btn.enabled = true
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_aliases_resolve() {
        verify(btn.labelItem)
        verify(btn.backgroundItem)
    }

    function test_text_round_trips() {
        btn.text = "Action"
        tryCompare(btn.labelItem, "text", "Action")
    }

    function test_clicked_fires() {
        btn.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_joins_tab_focus_chain() {
        compare(btn.activeFocusOnTab, true)
        compare(btn.focusPolicy, Qt.StrongFocus)
    }

    function test_space_emits_clicked_when_focused() {
        btn.forceActiveFocus()
        tryCompare(btn, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(clickedSpy.count, 1)
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

    function test_density_scales_the_button_data() {
        return [
            { tag: "compact",     density: "compact",     size: 31 },
            { tag: "comfortable", density: "comfortable", size: 36 },
            { tag: "touch",       density: "touch",       size: 44 },
        ]
    }

    function test_density_scales_the_button(data) {
        ThemeManager.setDensity(data.density)
        compare(btn.background.implicitWidth, data.size)
        compare(btn.background.implicitHeight, data.size)
    }

    Component {
        id: withTooltip
        LogosToolButton {
            text: "T"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosToolButton { text: "T" }
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
