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
    Component { id: rowWithCaption; LogosListRow { width: 360; title: "Ana"; subtitle: "Weekly sync"; caption: "Bring screenshots from the lab." } }
    Component {
        id: rowWithMenu
        LogosListRow {
            width: 360
            title: "Message"
            menu: LogosMenu { LogosMenuItem { text: "Archive" } }
        }
    }
    Component { id: spyComp2; SignalSpy {} }
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

    // A highlighted row's background stops above its separator; without a
    // separator it fills the row.
    function test_highlight_stops_above_the_separator() {
        const r = createRendered(row)
        r.selected = true
        compare(r.backgroundItem.height, r.height - Theme.size.borderWidth)
        compare(r.separatorItem.y, r.height - Theme.size.borderWidth)
        r.showSeparator = false
        compare(r.backgroundItem.height, r.height)
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
        const clicked = createTemporaryObject(spyComponent, root, { target: r.accessory, signalName: "clicked" })
        mouseClick(r, 20, r.height / 2)
        verify(r.accessory.checked)
        compare(toggled.count, 1)
        compare(clicked.count, 1)
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

    // A third line, e.g. an inbox row's preview, under the subtitle.
    function test_caption_is_a_third_line() {
        const r = createTemporaryObject(rowWithCaption, root)
        waitForRendering(r)
        verify(r.captionItem.visible)
        verify(r.captionItem.mapToItem(r, 0, 0).y > r.subtitleItem.mapToItem(r, 0, 0).y)
        compare(r.Accessible.description, "Weekly sync, Bring screenshots from the lab.")
        verify(r.height >= r.captionItem.mapToItem(r, 0, r.captionItem.height).y)
    }

    // The row's actions: a visible ⋯, a fingertip each way, that opens them.
    function test_menu_shows_a_more_button() {
        const r = createTemporaryObject(rowWithMenu, root)
        waitForRendering(r)
        verify(r.menuButtonItem.visible)
        compare(r.menuButtonItem.width, Theme.size.touchTarget)
        const clicked = createTemporaryObject(spyComp2, root, { target: r, signalName: "clicked" })
        mouseClick(r.menuButtonItem)
        tryCompare(r.menu, "opened", true)
        compare(clicked.count, 0, "the ⋯ isn't a tap on the row")
        r.menu.close()
    }

    // Long press or right-click on the row opens them too, without a tap.
    function test_long_press_on_the_row_opens_its_menu() {
        const r = createTemporaryObject(rowWithMenu, root)
        waitForRendering(r)
        const clicked = createTemporaryObject(spyComp2, root, { target: r, signalName: "clicked" })
        mousePress(r, 40, r.height / 2)
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        mouseRelease(r, 40, r.height / 2)
        tryCompare(r.menu, "opened", true)
        compare(clicked.count, 0)
        r.menu.close()
        tryCompare(r.menu, "visible", false)
        mouseClick(r, 40, r.height / 2, Qt.RightButton)
        tryCompare(r.menu, "opened", true)
        r.menu.close()
    }

    function test_no_menu_no_more_button() {
        const r = createTemporaryObject(row, root)
        verify(!r.menuButtonItem.visible)
    }
}
