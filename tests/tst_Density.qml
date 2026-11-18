import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

// Density is the host's choice and reaches every view. At touch density every
// tappable part is at least Theme.size.touchTarget each way and nothing needs
// hover; comfortable, the desktop default, keeps the desktop's sizes and
// behaviour.
TestCase {
    id: tc
    name: "Density"
    width: 800
    height: 600
    // TestCase is invisible by default, and input can't reach anything in an
    // invisible item.
    visible: true
    when: windowShown

    function cleanup() {
        ThemeManager.setDensity("")
    }

    function cleanupTestCase() {
        ThemeTestHelper.closeOtherEngine()
    }

    // ─── The host's choice ───

    function test_defaultIsComfortableOnDesktop() {
        compare(Theme.density, "comfortable")
        verify(!Theme.touch)
    }

    function test_setDensitySwitchesAndSaves() {
        verify(ThemeManager.setDensity("touch"))
        compare(Theme.density, "touch")
        verify(Theme.touch)
        compare(ThemeTestHelper.savedDensity(), "touch")

        verify(ThemeManager.setDensity("compact"))
        compare(Theme.density, "compact")
        verify(!Theme.touch)
        compare(ThemeTestHelper.savedDensity(), "compact")
    }

    function test_emptyGoesBackToTheDefault() {
        ThemeManager.setDensity("touch")
        verify(ThemeManager.setDensity(""))
        compare(Theme.density, "comfortable")
        compare(ThemeTestHelper.savedDensity(), "")
    }

    function test_unknownDensityIsRefused() {
        ThemeManager.setDensity("touch")
        verify(!ThemeManager.setDensity("huge"))
        compare(Theme.density, "touch")
        compare(ThemeTestHelper.savedDensity(), "touch")
    }

    function test_savedDensityIsReadBack() {
        ThemeTestHelper.reloadWithSavedDensity("touch")
        compare(Theme.density, "touch")
        // A hand-edited file can hold anything.
        ThemeTestHelper.reloadWithSavedDensity("huge")
        compare(Theme.density, "comfortable")
    }

    function test_reachesOtherEngines() {
        ThemeManager.setDensity("touch")
        compare(ThemeTestHelper.fromOtherEngine("density"), "touch")
        compare(ThemeTestHelper.fromOtherEngine("buttonHeight"), 53)
        ThemeManager.setDensity("")
        compare(ThemeTestHelper.fromOtherEngine("density"), "comfortable")
        compare(ThemeTestHelper.fromOtherEngine("buttonHeight"), 44)
    }

    // ─── Token values ───

    function test_tokens_data() {
        return [
            { tag: "button.height",              group: "button",     key: "height",               compact: 37, comfortable: 44, touch: 53 },
            { tag: "button.compactHeight",       group: "button",     key: "compactHeight",        compact: 27, comfortable: 32, touch: 44 },
            { tag: "button.paddingX",            group: "button",     key: "paddingX",             compact: 14, comfortable: 16, touch: 19 },
            { tag: "button.compactPaddingX",     group: "button",     key: "compactPaddingX",      compact: 10, comfortable: 12, touch: 14 },
            { tag: "field.height",               group: "field",      key: "height",               compact: 34, comfortable: 40, touch: 48 },
            { tag: "field.paddingX",             group: "field",      key: "paddingX",             compact: 10, comfortable: 12, touch: 14 },
            { tag: "search.height",              group: "search",     key: "height",               compact: 46, comfortable: 54, touch: 65 },
            { tag: "combo.height",               group: "combo",      key: "height",               compact: 27, comfortable: 32, touch: 44 },
            { tag: "listItem.height",            group: "listItem",   key: "height",               compact: 31, comfortable: 36, touch: 44 },
            { tag: "listItem.paddingX",          group: "listItem",   key: "paddingX",             compact: 10, comfortable: 12, touch: 14 },
            { tag: "menuItem.height",            group: "menuItem",   key: "height",               compact: 27, comfortable: 32, touch: 44 },
            { tag: "menuItem.paddingX",          group: "menuItem",   key: "paddingX",             compact: 10, comfortable: 12, touch: 14 },
            { tag: "tab.height",                 group: "tab",        key: "height",               compact: 34, comfortable: 40, touch: 48 },
            { tag: "tab.paddingX",               group: "tab",        key: "paddingX",             compact: 7,  comfortable: 8,  touch: 10 },
            { tag: "toolButton.size",            group: "toolButton", key: "size",                 compact: 31, comfortable: 36, touch: 44 },
            { tag: "iconButton.size",            group: "iconButton", key: "size",                 compact: 34, comfortable: 40, touch: 48 },
            // Controls that only change at touch density.
            { tag: "spinBox.height",             group: "spinBox",    key: "height",               compact: 32, comfortable: 32, touch: 48 },
            { tag: "spinBox.buttonWidth",        group: "spinBox",    key: "buttonWidth",          compact: 28, comfortable: 28, touch: 44 },
            { tag: "paginator.buttonSize",       group: "paginator",  key: "buttonSize",           compact: 36, comfortable: 36, touch: 44 },
            { tag: "paginator.buttonMinWidth",   group: "paginator",  key: "buttonMinWidth",       compact: 24, comfortable: 24, touch: 44 },
            { tag: "table.headerHeight",         group: "table",      key: "headerHeight",         compact: 36, comfortable: 36, touch: 44 },
            { tag: "table.selectionColumnWidth", group: "table",      key: "selectionColumnWidth", compact: 40, comfortable: 40, touch: 44 },
            { tag: "tile.size",                  group: "tile",       key: "size",                 compact: 40, comfortable: 40, touch: 48 },
        ]
    }

    function test_tokens(data) {
        for (const density of ["compact", "comfortable", "touch"]) {
            ThemeManager.setDensity(density)
            compare(Theme.controls[data.group][data.key], data[density], density)
        }
    }

    // ─── Touch targets ───

    Component { id: button;          LogosButton { text: "OK" } }
    Component { id: compactButton;   LogosButton { text: "OK"; compact: true } }
    Component { id: iconButton;      LogosIconButton {} }
    Component { id: smallIconButton; LogosIconButton { size: 20; iconSize: 12 } }
    Component { id: copyButton;      LogosCopyButton { value: "x" } }
    Component { id: copyableText;    LogosCopyableText { text: "0xabc" } }
    Component { id: toolButton;      LogosToolButton { text: "T" } }
    Component { id: textField;       LogosTextField {} }
    Component { id: comboBox;        LogosComboBox { model: ["a", "b"] } }
    Component { id: spinBox;         LogosSpinBox {} }
    Component { id: checkbox;        LogosCheckbox {} }
    Component { id: labelledCheckbox; LogosCheckbox { text: "Label" } }
    Component { id: radio;           LogosRadioButton {} }
    Component { id: toggle;          LogosSwitch {} }
    Component { id: slider;          LogosSlider {} }
    Component { id: infoButton;      LogosInfoButton { text: "Why" } }
    Component { id: link;            LogosLink { text: "A" } }
    Component { id: tile;            LogosTile { label: "AB" } }
    Component { id: smallTile;       LogosTile { label: "AB"; tileSize: 24 } }
    Component { id: tabButton;       LogosTabButton { text: "A" } }
    Component { id: listItem;        LogosItemDelegate { text: "Row" } }
    Component { id: menuItem;        LogosMenuItem { text: "Item" } }
    Component { id: stageLane;       LogosStageLane { interactive: true } }

    function test_touchTargets_data() {
        return [
            { tag: "LogosButton",           component: button },
            { tag: "LogosButton compact",   component: compactButton },
            { tag: "LogosIconButton",       component: iconButton },
            { tag: "LogosIconButton small", component: smallIconButton },
            { tag: "LogosCopyButton",       component: copyButton },
            { tag: "LogosCopyableText",     component: copyableText },
            { tag: "LogosToolButton",       component: toolButton },
            { tag: "LogosTextField",        component: textField },
            { tag: "LogosComboBox",         component: comboBox },
            { tag: "LogosSpinBox",          component: spinBox },
            { tag: "LogosCheckbox",         component: checkbox },
            { tag: "LogosCheckbox labelled", component: labelledCheckbox },
            { tag: "LogosRadioButton",      component: radio },
            { tag: "LogosSwitch",           component: toggle },
            { tag: "LogosSlider",           component: slider },
            { tag: "LogosInfoButton",       component: infoButton },
            { tag: "LogosLink",             component: link },
            { tag: "LogosTile",             component: tile },
            { tag: "LogosTile small",       component: smallTile },
            { tag: "LogosTabButton",        component: tabButton },
            { tag: "LogosItemDelegate",     component: listItem },
            { tag: "LogosMenuItem",         component: menuItem },
            { tag: "LogosStageLane",        component: stageLane },
        ]
    }

    function test_touchTargets(data) {
        ThemeManager.setDensity("touch")
        const item = createTemporaryObject(data.component, tc)
        verify(item)
        verify(item.implicitWidth >= Theme.size.touchTarget, "width " + item.implicitWidth)
        verify(item.implicitHeight >= Theme.size.touchTarget, "height " + item.implicitHeight)
    }

    // The look stays the size it was; only the area that takes the tap grows.
    function test_touchKeepsTheLook() {
        ThemeManager.setDensity("touch")
        const info = createTemporaryObject(infoButton, tc)
        compare(info.ringItem.width, Theme.controls.infoButton.size)
        const small = createTemporaryObject(smallIconButton, tc)
        compare(small.backgroundItem.width, 20)
        const box = createTemporaryObject(checkbox, tc)
        compare(box.indicator.width, Theme.controls.checkbox.indicatorSize)
        const t = createTemporaryObject(smallTile, tc)
        compare(t.background.width, 24)
    }

    Component { id: searchBar; LogosSearchBar {} }
    Component { id: notice;    LogosNotice { title: "Saved"; closable: true } }
    Component { id: paginator; LogosPaginator { totalCount: 100; pageSize: 10 } }

    function test_touchTargetsInsideControls() {
        ThemeManager.setDensity("touch")
        const search = createTemporaryObject(searchBar, tc)
        search.textInput.text = "abc"
        verify(search.clearItem.implicitWidth >= Theme.size.touchTarget)
        verify(search.clearItem.implicitHeight >= Theme.size.touchTarget)

        const n = createTemporaryObject(notice, tc)
        verify(n.closeButtonItem.implicitWidth >= Theme.size.touchTarget)
        verify(n.closeButtonItem.implicitHeight >= Theme.size.touchTarget)

        const p = createTemporaryObject(paginator, tc)
        for (const b of [p.firstButton, p.prevButton, p.nextButton, p.lastButton]) {
            verify(b.implicitWidth >= Theme.size.touchTarget)
            verify(b.implicitHeight >= Theme.size.touchTarget)
        }
        const cell = p.pageCells.itemAt(0)
        verify(cell.width >= Theme.size.touchTarget && cell.height >= Theme.size.touchTarget)
    }

    function test_comfortableKeepsDesktopSizes() {
        compare(createTemporaryObject(copyButton, tc).implicitWidth, 24)
        compare(createTemporaryObject(smallIconButton, tc).implicitWidth, 20)
        compare(createTemporaryObject(infoButton, tc).implicitWidth, 16)
        compare(createTemporaryObject(smallTile, tc).implicitWidth, 24)
        compare(createTemporaryObject(stageLane, tc).implicitHeight, 30)
        const l = createTemporaryObject(link, tc)
        compare(l.implicitHeight, l.labelItem.implicitHeight)
    }

    // ─── Nothing needs hover ───

    Component {
        id: labelWithTip
        LogosText {
            text: "A long name"
            readonly property alias tip: tip
            LogosToolTip { id: tip; text: "A long name, in full" }
        }
    }

    // Input reaches a new item once it has been rendered.
    function create(component, properties) {
        const item = createTemporaryObject(component, tc, properties || {})
        waitForRendering(item)
        return item
    }

    function holdOn(item) {
        mousePress(item)
        wait(Qt.styleHints.mousePressAndHoldInterval + 300)
        mouseRelease(item)
    }

    Component { id: buttonTip;     LogosButton { text: "OK"; LogosToolTip { text: "Tip" } } }
    Component { id: iconButtonTip; LogosIconButton { LogosToolTip { text: "Tip" } } }
    Component { id: linkTip;       LogosLink { text: "Docs"; LogosToolTip { text: "Tip" } } }
    Component { id: tileTip;       LogosTile { label: "AB"; LogosToolTip { text: "Tip" } } }
    Component { id: toolButtonTip; LogosToolButton { text: "T"; LogosToolTip { text: "Tip" } } }
    Component { id: tabButtonTip;  LogosTabButton { text: "Tab"; LogosToolTip { text: "Tip" } } }
    Component { id: checkboxTip;   LogosCheckbox { text: "Box"; LogosToolTip { text: "Tip" } } }
    Component { id: radioTip;      LogosRadioButton { text: "Radio"; LogosToolTip { text: "Tip" } } }
    Component { id: toggleTip;     LogosSwitch { text: "Switch"; LogosToolTip { text: "Tip" } } }
    Component { id: listItemTip;   LogosItemDelegate { text: "Row"; width: 200; LogosToolTip { text: "Tip" } } }
    Component { id: menuItemTip;   LogosMenuItem { text: "Item"; width: 200; LogosToolTip { text: "Tip" } } }
    Component { id: clickSpy; SignalSpy {} }

    function tipIn(control) {
        for (let i = 0; i < control.data.length; ++i)
            if (control.data[i] instanceof LogosToolTip)
                return control.data[i]
        return null
    }

    function spyOnClicks(control, signalName) {
        return createTemporaryObject(clickSpy, tc, { target: control, signalName: signalName || "clicked" })
    }

    function test_longPress_data() {
        return [
            { tag: "LogosButton",       withTip: buttonTip,     without: button },
            { tag: "LogosIconButton",   withTip: iconButtonTip, without: iconButton },
            { tag: "LogosLink",         withTip: linkTip,       without: link, signal: "activated" },
            { tag: "LogosTile",         withTip: tileTip,       without: tile },
            { tag: "LogosToolButton",   withTip: toolButtonTip, without: toolButton },
            { tag: "LogosTabButton",    withTip: tabButtonTip,  without: tabButton },
            { tag: "LogosCheckbox",     withTip: checkboxTip,   without: labelledCheckbox },
            { tag: "LogosRadioButton",  withTip: radioTip,      without: radio },
            { tag: "LogosSwitch",       withTip: toggleTip,     without: toggle },
            { tag: "LogosItemDelegate", withTip: listItemTip,   without: listItem },
            { tag: "LogosMenuItem",     withTip: menuItemTip,   without: menuItem },
        ]
    }

    // On touch a long-press shows what a control does, without doing it; a
    // tap still does it.
    function test_longPress(data) {
        ThemeManager.setDensity("touch")
        const c = create(data.withTip)
        const clicked = spyOnClicks(c, data.signal)
        holdOn(c)
        tryCompare(tipIn(c), "opened", true)
        compare(clicked.count, 0)
        mouseClick(c)
        compare(clicked.count, 1)
    }

    function test_longPressWithoutTip_data() { return test_longPress_data() }

    // Without a tip, a long-press is a click at touch density too: people who
    // press slowly must still get one.
    function test_longPressWithoutTip(data) {
        ThemeManager.setDensity("touch")
        const c = create(data.without)
        const clicked = spyOnClicks(c, data.signal)
        holdOn(c)
        compare(clicked.count, 1)
    }

    function test_longPressOnDesktop_data() { return test_longPress_data() }

    function test_longPressOnDesktop(data) {
        const c = create(data.withTip)
        const clicked = spyOnClicks(c, data.signal)
        holdOn(c)
        compare(clicked.count, 1)
        verify(!tipIn(c).opened)
    }

    Component {
        id: buttonWithLookAlike
        LogosIconButton {
            QtObject { property bool openOnLongPress: true }
        }
    }

    // Only a LogosToolTip counts.
    function test_longPressIgnoresLookAlikes() {
        ThemeManager.setDensity("touch")
        const b = create(buttonWithLookAlike)
        const clicked = spyOnClicks(b)
        holdOn(b)
        compare(clicked.count, 1)
    }

    Component {
        id: buttonWithLateTip
        LogosIconButton {
            id: lateButton
            property string problem: ""
            LogosToolTip { text: lateButton.problem }
        }
    }

    // An empty tip doesn't count until it has text.
    function test_tipCountsOnceItHasText() {
        ThemeManager.setDensity("touch")
        const b = create(buttonWithLateTip)
        const clicked = spyOnClicks(b)
        holdOn(b)
        compare(clicked.count, 1)
        b.problem = "Out of funds"
        holdOn(b)
        tryCompare(tipIn(b), "opened", true)
        compare(clicked.count, 1)
    }

    function test_switchingToTouchAppliesToExistingControls() {
        const c = create(checkboxTip)
        ThemeManager.setDensity("touch")
        holdOn(c)
        tryCompare(tipIn(c), "opened", true)
        verify(!c.checked)
    }

    // A tip on something that isn't a button, e.g. a cut-off label.
    function test_longPressOpensLabelTipOnTouch() {
        ThemeManager.setDensity("touch")
        const l = create(labelWithTip)
        holdOn(l)
        tryCompare(l.tip, "opened", true)
        mouseClick(l)
        tryCompare(l.tip, "opened", false)
    }

    function test_longPressOnLabelDoesNothingOnDesktop() {
        const l = create(labelWithTip)
        holdOn(l)
        wait(400)
        verify(!l.tip.opened)
    }

    Component { id: toast; LogosToast { duration: 300; title: "Saved" } }

    function test_tapHoldsToastOnTouch() {
        ThemeManager.setDensity("touch")
        const t = create(toast)
        t.show()
        mouseClick(t.titleItem)
        mouseMove(tc, tc.width - 1, tc.height - 1)  // not held by hover
        wait(t.duration * 2)
        verify(t.shown)
        t.show()
        tryCompare(t, "shown", false, t.duration * 10)
    }

    function test_clickDoesNotHoldToastOnDesktop() {
        const t = create(toast)
        t.show()
        mouseClick(t.titleItem)
        mouseMove(tc, tc.width - 1, tc.height - 1)
        tryCompare(t, "shown", false, t.duration * 10)
    }

    Component { id: plainLink; LogosLink { text: "Docs"; underline: false } }

    function test_linkUnderlinedOnTouch() {
        const l = createTemporaryObject(plainLink, tc)
        verify(!l.labelItem.font.underline)
        ThemeManager.setDensity("touch")
        verify(l.labelItem.font.underline)
    }

    ListModel {
        id: rows
        ListElement { name: "a" }
        ListElement { name: "b" }
    }

    Component {
        id: table
        LogosTable {
            width: 400
            height: 300
            selectionMode: LogosTable.Multi
            model: rows
            columns: [ LogosTableColumn { title: "Name"; role: "name" } ]
        }
    }

    // Next to the checkbox, inside its cell: the top-left corner of row 0.
    function clickBesideCheckbox(t) {
        const p = t.view.itemAtIndex(0).mapToItem(t, 2, 2)
        mouseClick(t, p.x, p.y)
    }

    function test_checkboxCellTogglesRowOnTouch() {
        ThemeManager.setDensity("touch")
        const t = create(table)
        const clicked = createTemporaryObject(rowClickSpy, tc, { target: t })
        clickBesideCheckbox(t)
        compare(t.selectedIndices, [0])
        compare(clicked.count, 0)
    }

    function test_checkboxCellIsRowOnDesktop() {
        const t = create(table)
        const clicked = createTemporaryObject(rowClickSpy, tc, { target: t })
        clickBesideCheckbox(t)
        compare(t.selectedIndices, [])
        compare(clicked.count, 1)
    }

    Component { id: rowClickSpy; SignalSpy { signalName: "rowClicked" } }
}
