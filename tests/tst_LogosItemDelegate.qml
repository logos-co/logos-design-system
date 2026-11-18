import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosItemDelegate"
    width: 300
    height: 50
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    LogosItemDelegate {
        id: item
        text: "Open"
    }

    SignalSpy {
        id: clickedSpy
        target: item
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        item.text = "Open"
        item.enabled = true
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_aliases_resolve() {
        verify(item.backgroundItem)
        verify(item.labelItem)
    }

    function test_text_round_trips() {
        item.text = "Save"
        tryCompare(item.labelItem, "text", "Save")
    }

    function test_clicked_fires() {
        item.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_joins_tab_focus_chain() {
        compare(item.activeFocusOnTab, true)
        compare(item.focusPolicy, Qt.StrongFocus)
    }

    function test_space_emits_clicked_when_focused() {
        item.forceActiveFocus()
        tryCompare(item, "activeFocus", true)
        keyClick(Qt.Key_Space)
        compare(clickedSpy.count, 1)
    }

    function test_label_uses_theme_font_family() {
        // `font: root.font` used to replace the label's family with the
        // Control default (system sans) instead of Public Sans.
        compare(item.labelItem.font.family, Theme.typography.publicSans)
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
            { tag: "compact", density: "compact", height: 31, paddingX: 10 },
            { tag: "comfortable", density: "comfortable", height: 36, paddingX: 12 },
            { tag: "touch", density: "touch", height: 44, paddingX: 14 },
        ]
    }

    function test_density_scales_height_and_side_padding(data) {
        ThemeManager.setDensity(data.density)
        compare(item.implicitHeight, data.height)
        compare(item.leftPadding, data.paddingX)
        compare(item.rightPadding, data.paddingX)
    }

    Component {
        id: withTooltip
        LogosItemDelegate {
            text: "Row"
            width: 200
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component {
        id: withoutTooltip
        LogosItemDelegate { text: "Row"; width: 200 }
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

    ListModel {
        id: tipRows
        ListElement { name: "a" }
        ListElement { name: "b" }
    }

    Component {
        id: listWithTips
        ListView {
            property int clicks: 0
            width: 200
            height: 50
            model: tipRows
            delegate: LogosItemDelegate {
                required property string name
                readonly property alias tip: tooltip
                text: name
                width: 200
                onClicked: ListView.view.clicks += 1
                LogosToolTip { id: tooltip; text: "Tip" }
            }
        }
    }

    // List rows are created lazily; a tooltip in one still opens on long-press.
    function test_touch_long_press_in_a_list_row() {
        ThemeManager.setDensity("touch")
        const list = createRendered(listWithTips)
        const row = list.itemAtIndex(0)
        holdOn(row)
        tryCompare(row.tip, "opened", true)
        compare(list.clicks, 0)
    }
}
