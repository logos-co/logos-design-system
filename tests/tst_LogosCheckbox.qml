import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosCheckbox"
    width: 400
    height: 200
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosCheckbox {
        id: cbox
        text: "Accept"
    }

    SignalSpy {
        id: clickedSpy
        target: cbox
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        cbox.checked = false
        cbox.enabled = true
        cbox.text = "Accept"
        cbox.focus = false
    }

    // A test that switches theme or density and fails must not leave it switched.
    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
        ThemeManager.select("dark")
    }

    // The checkmark sits on the primary fill.
    function test_checkmark_uses_primary_foreground() {
        verify(ThemeManager.select("test.light"))
        verify(!Qt.colorEqual(Theme.palette.primaryForeground, Theme.palette.text))
        compare(cbox.checkmarkColor, Theme.palette.primaryForeground)
    }

    function test_renders_text() {
        compare(cbox.text, "Accept")
    }

    function test_text_setter_updates_label() {
        cbox.text = "Updated"
        tryCompare(cbox.labelItem, "text", "Updated")
    }

    function test_checked_property_round_trips() {
        cbox.checked = true
        compare(cbox.checked, true)
        cbox.checked = false
        compare(cbox.checked, false)
    }

    function test_emits_clicked_when_invoked() {
        cbox.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_indicator_alias_resolves() {
        verify(cbox.indicatorItem, "indicatorItem alias must resolve")
        verify(cbox.focusRingItem, "focusRingItem alias must resolve")
    }

    function test_label_alias_resolves() {
        verify(cbox.labelItem, "labelItem alias must resolve")
    }

    function test_focus_ring_visible_when_keyboard_focused() {
        compare(cbox.focusRingItem.border.width, 0)
        // Clear any leftover focus so TabFocusReason is applied (forceActiveFocus
        // is a no-op when the item already has activeFocus).
        cbox.focus = false
        tryCompare(cbox, "activeFocus", false)
        cbox.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(cbox, "visualFocus", true)
        compare(cbox.focusRingItem.border.width, 2)
        compare(cbox.focusRingItem.border.color, Theme.palette.focus)

        // Still visible when checked (primary fill must not hide the ring).
        cbox.checked = true
        compare(cbox.focusRingItem.border.width, 2)
        compare(cbox.focusRingItem.border.color, Theme.palette.focus)
    }

    function test_label_color_switches_with_enabled() {
        cbox.enabled = true
        tryCompare(cbox.labelItem, "color", Theme.palette.text)
        cbox.enabled = false
        tryCompare(cbox.labelItem, "color", Theme.palette.textMuted)
    }

    function test_joins_tab_focus_chain() {
        compare(cbox.activeFocusOnTab, true)
        compare(cbox.focusPolicy, Qt.StrongFocus)
    }

    function test_space_toggles_when_focused() {
        cbox.forceActiveFocus()
        tryCompare(cbox, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(cbox.checked, true)
        compare(clickedSpy.count, 1)
    }

    function test_disabled_ignores_keyboard_activate() {
        cbox.enabled = false
        cbox.forceActiveFocus()
        keyClick(Qt.Key_Space)
        compare(cbox.checked, false)
        compare(clickedSpy.count, 0)
    }

    function test_label_uses_theme_font_family() {
        // `font: root.font` used to replace the label's family with the
        // Control default (system sans) instead of Public Sans.
        compare(cbox.labelItem.font.family, Theme.typography.publicSans)
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

    function test_touch_row_reaches_the_touch_target_and_the_box_keeps_its_size() {
        ThemeManager.setDensity("touch")
        const c = createRendered(withoutTooltip)
        verify(c.implicitWidth >= Theme.size.touchTarget)
        verify(c.implicitHeight >= Theme.size.touchTarget)
        compare(c.indicator.width, Theme.controls.checkbox.indicatorSize)
    }

    function test_desktop_row_hugs_the_box() {
        const c = createRendered(withoutTooltip)
        compare(c.implicitHeight, Theme.controls.checkbox.indicatorSize + c.topPadding + c.bottomPadding)
    }

    Component {
        id: withTooltip
        LogosCheckbox {
            text: "Box"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosCheckbox { text: "Box" }
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
