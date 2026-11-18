import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

TestCase {
    id: root
    name: "LogosListRow"
    width: 400
    height: 200
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component { id: row; LogosListRow { width: 360; title: "Network"; value: "Testnet"; showChevron: true } }
    Component { id: rowWithIcon; LogosListRow { width: 360; title: "Download folder"; iconSource: "qrc:/test-icon.png" } }
    Component { id: rowWithSubtitle; LogosListRow { width: 360; title: "Network"; subtitle: "Where the node connects" } }
    Component { id: switchRow; LogosListRow { width: 360; title: "Notifications"; accessory: LogosSwitch {} } }
    Component { id: disabledSwitchRow; LogosListRow { width: 360; title: "Notifications"; accessory: LogosSwitch { enabled: false } } }
    Component {
        id: rowWithTooltip
        LogosListRow {
            width: 360
            title: "Network"
            readonly property alias tip: tooltip
            LogosToolTip { id: tooltip; text: "Tip" }
        }
    }
    Component { id: spyComponent; SignalSpy {} }

    function createRendered(component) {
        const item = createTemporaryObject(component, root)
        waitForRendering(item)
        return item
    }

    function cleanup() {
        ThemeManager.setDensity("")
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_heights_data() {
        return [
            { tag: "compact",     density: "compact",     plain: 44, withSubtitle: 54 },
            { tag: "comfortable", density: "comfortable", plain: 52, withSubtitle: 64 },
            { tag: "touch",       density: "touch",       plain: 62, withSubtitle: 77 },
        ]
    }

    function test_heights(data) {
        ThemeManager.setDensity(data.density)
        compare(createRendered(row).implicitHeight, data.plain)
        compare(createRendered(rowWithSubtitle).implicitHeight, data.withSubtitle)
    }

    function test_shows_value_and_chevron() {
        const r = createRendered(row)
        verify(r.valueItem.visible)
        compare(r.valueItem.text, "Testnet")
        verify(r.chevronItem.visible)
        verify(!r.subtitleItem.visible)
    }

    function test_separator_starts_under_the_text_data() {
        return [
            { tag: "no icon", component: row },
            { tag: "icon",    component: rowWithIcon },
        ]
    }

    // The separator starts under the text, past any icon.
    function test_separator_starts_under_the_text(data) {
        const r = createRendered(data.component)
        compare(r.separatorItem.x, r.titleItem.mapToItem(r, 0, 0).x)
    }

    function test_selected_row_stands_out() {
        const r = createRendered(row)
        // A copy: a colour read from a property follows it.
        const idle = r.backgroundItem.color.toString()
        r.selected = true
        verify(r.backgroundItem.color.toString() !== idle)
    }

    function test_destructive_uses_the_error_colour() {
        const r = createRendered(row)
        r.destructive = true
        compare(r.titleItem.color, Theme.palette.error)
    }

    // A tap anywhere on the row toggles its switch, as a tap on the switch does.
    function test_row_tap_toggles_the_accessory() {
        const r = createRendered(switchRow)
        const toggled = createTemporaryObject(spyComponent, root, { target: r.accessory, signalName: "toggled" })
        mouseClick(r, 20, r.height / 2)
        verify(r.accessory.checked)
        compare(toggled.count, 1)
    }

    // A row tap is a tap on the switch, so a disabled switch stays as it is.
    function test_row_tap_leaves_a_disabled_accessory_alone() {
        const r = createRendered(disabledSwitchRow)
        const toggled = createTemporaryObject(spyComponent, root, { target: r.accessory, signalName: "toggled" })
        mouseClick(r, 20, r.height / 2)
        verify(!r.accessory.checked)
        compare(toggled.count, 0)
    }

    function test_clicked() {
        const r = createRendered(row)
        const clicked = createTemporaryObject(spyComponent, root, { target: r, signalName: "clicked" })
        mouseClick(r)
        compare(clicked.count, 1)
    }

    // At touch density a long-press shows the tooltip instead of clicking.
    function test_touch_long_press_opens_the_tooltip_instead_of_clicking() {
        ThemeManager.setDensity("touch")
        const r = createRendered(rowWithTooltip)
        const clicked = createTemporaryObject(spyComponent, root, { target: r, signalName: "clicked" })
        mousePress(r)
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        mouseRelease(r)
        tryCompare(r.tip, "opened", true)
        compare(clicked.count, 0)
    }
}
