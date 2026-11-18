import QtQuick
import QtTest

import Logos.Controls
import LogosTests

// Locks the shared interaction contract. LogosButton and LogosTile both
// inherit this; if it regresses, both regress together, which is exactly the
// drift this base was extracted to prevent.
TestCase {
    id: tc
    name: "LogosAbstractButton"
    width: 200
    height: 200
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosAbstractButton {
        id: btn
        implicitWidth: 100
        implicitHeight: 40
        Accessible.name: "probe"
    }

    SignalSpy {
        id: spy
        target: btn
        signalName: "clicked"
    }

    function init() {
        btn.enabled = true
        spy.clear()
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(tc, tc.width - 1, tc.height - 1)
    }

    // The base must own no content or chrome — that is what makes it safe to
    // extend. LogosButton could not be extended because its `text` aliases
    // into its own contentItem.
    function test_declares_no_content_or_background() {
        verify(!btn.contentItem, "base must not assign contentItem")
        verify(!btn.background, "base must not assign background")
    }

    function test_mouse_click_emits() {
        btn.mouseAreaItem.clicked(null)
        compare(spy.count, 1)
    }

    function test_disabled_does_not_emit() {
        btn.enabled = false
        btn.mouseAreaItem.clicked(null)
        compare(spy.count, 0)
    }

    function test_space_press_release_emits() {
        btn.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(btn, "pressed", true)
        keyRelease(Qt.Key_Space)
        tryCompare(btn, "pressed", false)
        compare(spy.count, 1)
    }

    function test_enter_emits() {
        btn.forceActiveFocus()
        keyPress(Qt.Key_Return)
        keyRelease(Qt.Key_Return)
        compare(spy.count, 1)
    }

    function test_disabled_key_does_not_press_or_emit() {
        btn.enabled = false
        btn.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(btn, "pressed", false)
        keyRelease(Qt.Key_Space)
        compare(spy.count, 0)
    }

    // Tab-away mid-press must not leave the control stuck pressed — no key
    // release ever arrives for it.
    function test_focus_loss_clears_held_key() {
        btn.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(btn, "pressed", true)
        btn.focus = false
        tryCompare(btn, "pressed", false)
    }

    function test_isActive_tracks_focus() {
        compare(btn.isActive, false)
        btn.forceActiveFocus()
        tryCompare(btn, "isActive", true)
    }

    // ---- Density and touch ----

    Component { id: longPressSpy; SignalSpy {} }

    // Input reaches a new item once it has been rendered.
    function createRendered(component, properties) {
        const item = createTemporaryObject(component, tc, properties || {})
        waitForRendering(item)
        return item
    }

    function holdOn(item) {
        mousePress(item)
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        mouseRelease(item)
    }

    function spyFor(target, signalName) {
        return createTemporaryObject(longPressSpy, tc, { target: target, signalName: signalName })
    }

    Component {
        id: withTooltip
        LogosAbstractButton {
            width: 80
            height: 40
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosAbstractButton { width: 80; height: 40 }
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
