import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosLink"
    width: 400
    height: 200
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosLink {
        id: link
        text: "Docs"
        href: "https://example.com/docs"
    }

    SignalSpy {
        id: activatedSpy
        target: link
        signalName: "activated"
    }

    function init() {
        link.text = "Docs"
        link.href = "https://example.com/docs"
        link.enabled = true
        link.underline = true
        link.linkColor = Theme.palette.primary
        link.hoverColor = Theme.palette.primaryHover
        activatedSpy.clear()
        // Keyboard tests leave activeFocus on the link; that paints hoverColor
        // via isActive and would flake color assertions.
        link.focus = false
        root.forceActiveFocus()
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    // ── Aliases ──────────────────────────────────────────────────────────

    function test_aliases_resolve() {
        verify(link.labelItem)
        verify(link.mouseAreaItem)
    }

    // ── Defaults / round-trips ───────────────────────────────────────────

    function test_label_tracks_text() {
        tryCompare(link.labelItem, "text", "Docs")
        link.text = "Guide"
        tryCompare(link.labelItem, "text", "Guide")
    }

    function test_underline_default_true() {
        compare(link.underline, true)
        compare(link.labelItem.font.underline, true)
    }

    function test_linkColor_flows_to_label() {
        tryCompare(link.labelItem, "color", Theme.palette.primary)
        link.linkColor = Theme.palette.info
        tryCompare(link.labelItem, "color", Theme.palette.info)
    }

    // ── Activation ───────────────────────────────────────────────────────

    function test_click_emits_activated_with_href() {
        link.mouseAreaItem.clicked(null)
        compare(activatedSpy.count, 1)
        compare(activatedSpy.signalArguments[0][0].toString(),
                "https://example.com/docs")
    }

    function test_activate_emits_activated() {
        link.activate()
        compare(activatedSpy.count, 1)
    }

    function test_disabled_does_not_activate() {
        link.enabled = false
        link.activate()
        compare(activatedSpy.count, 0)
    }

    function test_empty_href_still_emits_activated() {
        link.href = ""
        link.activate()
        compare(activatedSpy.count, 1)
        compare(activatedSpy.signalArguments[0][0].toString(), "")
    }

    function test_joins_tab_focus_chain() {
        compare(link.activeFocusOnTab, true)
        compare(link.focusPolicy, Qt.StrongFocus)
    }

    function test_space_emits_activated_when_focused() {
        link.forceActiveFocus()
        tryCompare(link, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(activatedSpy.count, 1)
    }

    function test_disabled_ignores_keyboard_activate() {
        link.enabled = false
        link.forceActiveFocus()
        keyClick(Qt.Key_Space)
        compare(activatedSpy.count, 0)
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

    function test_touch_pads_the_link_to_a_touch_target() {
        ThemeManager.setDensity("touch")
        verify(link.implicitWidth >= Theme.size.touchTarget)
        verify(link.implicitHeight >= Theme.size.touchTarget)
    }

    function test_desktop_link_is_its_label() {
        compare(link.implicitWidth, link.labelItem.implicitWidth)
        compare(link.implicitHeight, link.labelItem.implicitHeight)
    }

    // Without hover, a link has to look like one.
    function test_touch_always_underlines() {
        link.underline = false
        verify(!link.labelItem.font.underline)
        ThemeManager.setDensity("touch")
        verify(link.labelItem.font.underline)
    }

    Component {
        id: withTooltip
        LogosLink {
            text: "Docs"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosLink { text: "Docs" }
    }

    // At touch density a long-press shows the tooltip instead of doing the
    // action; a tap still does it.
    function test_touch_long_press_opens_the_tooltip_instead_of_clicking() {
        ThemeManager.setDensity("touch")
        const c = createRendered(withTooltip)
        const spy = spyFor(c, "activated")
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
        const spy = spyFor(c, "activated")
        holdOn(c)
        compare(spy.count, 1)
    }

    function test_desktop_long_press_clicks() {
        const c = createRendered(withTooltip)
        const spy = spyFor(c, "activated")
        holdOn(c)
        compare(spy.count, 1)
        verify(!c.tip.opened)
    }
}
