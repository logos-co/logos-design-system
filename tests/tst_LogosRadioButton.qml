import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosRadioButton"
    width: 200
    height: 100
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosRadioButton {
        id: rb
        text: "Pick me"
    }

    SignalSpy {
        id: clickedSpy
        target: rb
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        rb.checked = false
        rb.enabled = true
        rb.text = "Pick me"
        rb.focus = false
        root.forceActiveFocus()
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_aliases_resolve() {
        verify(rb.indicatorItem)
        verify(rb.focusRingItem)
        verify(rb.labelItem)
    }

    function test_checked_round_trips() {
        rb.checked = true
        compare(rb.checked, true)
    }

    function test_label_text_updates() {
        rb.text = "Selected"
        tryCompare(rb.labelItem, "text", "Selected")
    }

    function test_clicked_fires() {
        rb.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_focus_ring_visible_when_keyboard_focused() {
        compare(rb.focusRingItem.border.width, 0)
        // Clear any leftover focus so TabFocusReason is applied (forceActiveFocus
        // is a no-op when the item already has activeFocus).
        rb.focus = false
        tryCompare(rb, "activeFocus", false)
        rb.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(rb, "visualFocus", true)
        compare(rb.focusRingItem.border.width, 2)
        compare(rb.focusRingItem.border.color, Theme.palette.focus)

        // Still visible when checked (primary fill must not hide the ring).
        rb.checked = true
        compare(rb.focusRingItem.border.width, 2)
        compare(rb.focusRingItem.border.color, Theme.palette.focus)
    }

    function test_joins_tab_focus_chain() {
        compare(rb.activeFocusOnTab, true)
        compare(rb.focusPolicy, Qt.StrongFocus)
    }

    function test_space_checks_when_focused() {
        rb.forceActiveFocus()
        tryCompare(rb, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(rb.checked, true)
        compare(clickedSpy.count, 1)
    }

    function test_disabled_ignores_keyboard_activate() {
        rb.enabled = false
        rb.forceActiveFocus()
        keyClick(Qt.Key_Space)
        compare(rb.checked, false)
        compare(clickedSpy.count, 0)
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

    function test_touch_row_reaches_the_touch_target_and_the_dot_keeps_its_size() {
        ThemeManager.setDensity("touch")
        const r = createRendered(withoutTooltip)
        verify(r.implicitWidth >= Theme.size.touchTarget)
        verify(r.implicitHeight >= Theme.size.touchTarget)
        compare(r.indicator.width, Theme.controls.radio.indicatorSize)
    }

    function test_desktop_row_hugs_the_indicator() {
        const r = createRendered(withoutTooltip)
        compare(r.implicitHeight, Theme.controls.radio.indicatorSize + r.topPadding + r.bottomPadding)
    }

    Component {
        id: withTooltip
        LogosRadioButton {
            text: "Radio"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosRadioButton { text: "Radio" }
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
