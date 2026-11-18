import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosTabButton"
    width: 600
    height: 80
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    TabBar {
        id: bar
        width: root.width
        height: 40

        LogosTabButton {
            id: btn
            text: "Files"
            activeColor: "#FF0000"
            inactiveColor: "#888888"
        }
        LogosTabButton {
            id: btn2
            text: "Other"
        }
        LogosTabButton {
            id: btnWithIcon
            text: "WithIcon"
            iconSource: "qrc:/test-icon.png"
        }
    }

    function init() {
        bar.currentIndex = 1   // start with btn unchecked for a clean baseline
        bar.currentIndex = 0
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_renders_text() {
        compare(btn.text, "Files")
    }

    function test_active_color_when_checked() {
        bar.currentIndex = 0
        verify(btn.checked)
        compare(btn.labelItem.color.toString(), "#ff0000")
    }

    function test_inactive_color_when_unchecked() {
        bar.currentIndex = 1
        verify(!btn.checked)
        compare(btn.labelItem.color.toString(), "#888888")
    }

    function test_iconSource_empty_by_default() {
        compare(btn.iconSource.toString(), "")
    }

    function test_iconSource_round_trips() {
        compare(btnWithIcon.iconSource.toString(), "qrc:/test-icon.png")
    }

    function test_icon_holder_exists() {
        verify(btn.iconItem, "iconItem alias must resolve")
        verify(btnWithIcon.iconItem, "iconItem alias must resolve")
    }

    function test_focus_uses_underline_not_rectangle() {
        verify(btn.underlineItem, "underlineItem alias must resolve")
        bar.currentIndex = 1
        verify(!btn.checked)
        compare(btn.underlineItem.color, "#00000000")
        btn.forceActiveFocus(Qt.TabFocusReason)
        tryCompare(btn, "visualFocus", true)
        compare(btn.underlineItem.color, Theme.palette.overlayOrange)
        // Selected tab: underline stays transparent — LogosTabBar owns the indicator.
        bar.currentIndex = 0
        verify(btn.checked)
        compare(btn.underlineItem.color, "#00000000")
    }

    function test_joins_tab_focus_chain() {
        compare(btn.activeFocusOnTab, true)
        compare(btn.focusPolicy, Qt.StrongFocus)
    }

    function test_label_uses_theme_font_family() {
        // `font: root.font` used to replace the label's family with the
        // Control default (system sans) instead of Public Sans.
        compare(btn.labelItem.font.family, Theme.typography.publicSans)
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

    Component { id: shortTab; LogosTabButton { text: "A" } }

    function test_density_scales_height_and_side_padding_data() {
        return [
            { tag: "compact", density: "compact", height: 34, paddingX: 7 },
            { tag: "comfortable", density: "comfortable", height: 40, paddingX: 8 },
            { tag: "touch", density: "touch", height: 48, paddingX: 10 },
        ]
    }

    function test_density_scales_height_and_side_padding(data) {
        ThemeManager.setDensity(data.density)
        const t = createRendered(shortTab)
        compare(t.implicitHeight, data.height)
        compare(t.leftPadding, data.paddingX)
        compare(t.rightPadding, data.paddingX)
    }

    function test_touch_keeps_a_short_tab_touch_wide() {
        ThemeManager.setDensity("touch")
        verify(createRendered(shortTab).implicitWidth >= Theme.size.touchTarget)
    }

    Component {
        id: withTooltip
        LogosTabButton {
            text: "Tab"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosTabButton { text: "Tab" }
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
