import QtQuick
import QtTest

import Logos.Controls
import LogosTests
import Logos.Theme

TestCase {
    id: root
    name: "LogosSwitch"
    width: 200
    height: 100
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosSwitch {
        id: sw
        text: "Toggle"
    }

    SignalSpy {
        id: clickedSpy
        target: sw
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        sw.checked = false
        sw.enabled = true
        sw.text = "Toggle"
    }

    // A test that switches theme or density and fails must not leave it switched.
    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
        ThemeManager.select("dark")
    }

    // On, the handle sits on the primary track.
    function test_handle_colour_follows_the_track() {
        verify(ThemeManager.select("test.light"))
        verify(!Qt.colorEqual(Theme.palette.primaryForeground, Theme.palette.text))
        compare(sw.handleItem.color, Theme.palette.text)
        sw.checked = true
        compare(sw.handleItem.color, Theme.palette.primaryForeground)
    }

    function test_aliases_resolve() {
        verify(sw.indicatorItem)
        verify(sw.handleItem)
        verify(sw.labelItem)
        verify(sw.focusRingItem)
    }

    function test_focus_ring_visible_when_keyboard_focused() {
        compare(sw.focusRingItem.border.width, 0)
        sw.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(sw, "visualFocus", true)
        compare(sw.focusRingItem.border.width, 2)
        compare(sw.focusRingItem.border.color, Theme.palette.focus)

        // Still visible when checked (primary track must not hide the ring).
        sw.checked = true
        compare(sw.focusRingItem.border.width, 2)
        compare(sw.focusRingItem.border.color, Theme.palette.focus)
    }


    function test_checked_round_trips() {
        sw.checked = true
        compare(sw.checked, true)
    }

    function test_label_text_updates() {
        sw.text = "On"
        tryCompare(sw.labelItem, "text", "On")
    }

    function test_clicked_fires() {
        sw.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_handle_position_updates() {
        sw.checked = true
        tryVerify(function() { return sw.handleItem.x > 2 })
        sw.checked = false
        tryCompare(sw.handleItem, "x", 2)
    }

    function test_joins_tab_focus_chain() {
        compare(sw.activeFocusOnTab, true)
        compare(sw.focusPolicy, Qt.StrongFocus)
    }

    function test_space_toggles_when_focused() {
        sw.forceActiveFocus()
        tryCompare(sw, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(sw.checked, true)
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

    function test_touch_row_reaches_the_touch_target_and_the_track_keeps_its_size() {
        ThemeManager.setDensity("touch")
        const s = createRendered(withoutTooltip)
        verify(s.implicitWidth >= Theme.size.touchTarget)
        verify(s.implicitHeight >= Theme.size.touchTarget)
        compare(s.indicatorItem.width, Theme.controls.toggle.trackWidth)
        compare(s.indicatorItem.height, Theme.controls.toggle.trackHeight)
    }

    function test_desktop_row_is_not_touch_tall() {
        verify(createRendered(withoutTooltip).implicitHeight < Theme.size.touchTarget)
    }

    Component {
        id: withTooltip
        LogosSwitch {
            text: "Switch"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosSwitch { text: "Switch" }
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
        verify(!c.checked)
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
