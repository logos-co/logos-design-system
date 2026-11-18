import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosIconButton"
    width: 400
    height: 200
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosIconButton {
        id: btn
        iconSource: "qrc:/test-icon.png"
        anchors.centerIn: parent
    }

    SignalSpy {
        id: clickedSpy
        target: btn
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        btn.enabled = true
        btn.iconSource = "qrc:/test-icon.png"
        btn.size = 40
        btn.iconSize = 20
        btn.flat = false
        btn.focus = false
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_flat_hides_pill_background() {
        compare(btn.flat, false)
        // Item.visible reads *effective* visibility, which is false for the
        // whole TestCase subtree in the offscreen harness — so only the
        // flat → hidden direction is assertable here.
        btn.flat = true
        compare(btn.backgroundItem.visible, false)
    }

    function test_iconSource_round_trips() {
        btn.iconSource = "qrc:/test-icon.png"
        compare(btn.iconSource.toString(), "qrc:/test-icon.png")
    }

    function test_iconSource_can_be_cleared() {
        btn.iconSource = ""
        compare(btn.iconSource.toString(), "")
    }

    function test_size_drives_implicit_dimensions() {
        btn.size = 32
        compare(btn.implicitWidth, 32)
        compare(btn.implicitHeight, 32)
    }

    function test_iconSize_drives_image_dimensions() {
        btn.iconSize = 24
        compare(btn.iconImage.width, 24)
        compare(btn.iconImage.height, 24)
    }

    function test_emits_clicked_when_enabled() {
        btn.mouseAreaItem.clicked(null)
        compare(clickedSpy.count, 1)
    }

    function test_disabled_propagates_to_mousearea() {
        btn.enabled = false
        compare(btn.mouseAreaItem.enabled, false)
        btn.enabled = true
        compare(btn.mouseAreaItem.enabled, true)
    }

    function test_inspection_aliases_resolve() {
        verify(btn.iconImage, "iconImage must resolve")
        verify(btn.backgroundItem, "backgroundItem must resolve")
        verify(btn.mouseAreaItem, "mouseAreaItem must resolve")
    }

    function test_resting_colors() {
        compare(btn.isActive, false)
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundButton)
        tryCompare(btn.backgroundItem.border, "color", Theme.palette.borderStrong)
    }

    function test_hover_or_focus_uses_muted_fill() {
        compare(btn._backgroundColor(true, false, false, false), Theme.palette.backgroundButton)
        compare(btn._backgroundColor(true, false, true, false), Theme.palette.backgroundMuted)
        compare(btn._backgroundColor(true, false, false, true), Theme.palette.backgroundMuted)

        btn.forceActiveFocus()
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundMuted)
        tryCompare(btn.backgroundItem.border, "color", Theme.palette.overlayOrange)
    }

    function test_pressed_uses_stronger_fill_than_hover() {
        // Pressed wins over hover/focus, matching LogosButton secondary.
        compare(btn._backgroundColor(true, true, true, false), Theme.palette.background)
        compare(btn._backgroundColor(true, true, false, false), Theme.palette.background)
        compare(btn._backgroundColor(true, false, true, false), Theme.palette.backgroundMuted)
    }

    function test_disabled_is_never_active() {
        btn.enabled = false
        btn.forceActiveFocus()
        verify(!btn.isActive)
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundButton)
        tryCompare(btn.backgroundItem.border, "color", Theme.palette.borderStrong)
        compare(btn._backgroundColor(false, true, true, true), Theme.palette.backgroundButton)
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

    function test_disabled_ignores_keyboard_activate() {
        btn.enabled = false
        btn.forceActiveFocus()
        keyClick(Qt.Key_Space)
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

    Component { id: sizedButton; LogosIconButton {} }

    function test_touch_pads_a_small_button_and_keeps_its_look() {
        ThemeManager.setDensity("touch")
        const b = createRendered(sizedButton, { size: 20 })
        compare(b.implicitWidth, Theme.size.touchTarget)
        compare(b.implicitHeight, Theme.size.touchTarget)
        compare(b.backgroundItem.width, 20)
        compare(b.backgroundItem.x, (Theme.size.touchTarget - 20) / 2)
    }

    function test_touch_leaves_a_big_enough_button_alone() {
        ThemeManager.setDensity("touch")
        const b = createRendered(sizedButton, { size: 48 })
        compare(b.implicitWidth, 48)
        compare(b.backgroundItem.width, 48)
    }

    Component {
        id: withTooltip
        LogosIconButton {
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosIconButton {}
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
