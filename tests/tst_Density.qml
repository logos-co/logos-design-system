import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

// Density is the host's choice and reaches every view, and at touch density
// every tappable control is at least Theme.size.touchTarget each way. Each
// control's own density and touch behaviour is tested in its own file.
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
            { tag: "button.paddingY",            group: "button",     key: "paddingY",             compact: 10, comfortable: 12, touch: 14 },
            { tag: "button.compactPaddingY",     group: "button",     key: "compactPaddingY",      compact: 7,  comfortable: 8,  touch: 10 },
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

    // ─── LongPressToolTips ───
    // Each control's own long-press cases are in its own test file; these are
    // the helper's edge cases.

    Component { id: clickSpy; SignalSpy {} }

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

    function tipIn(control) {
        for (let i = 0; i < control.data.length; ++i)
            if (control.data[i] instanceof LogosToolTip)
                return control.data[i]
        return null
    }

    function spyOnClicks(control) {
        return createTemporaryObject(clickSpy, tc, { target: control, signalName: "clicked" })
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

    Component { id: checkboxTip; LogosCheckbox { text: "Box"; LogosToolTip { text: "Tip" } } }

    function test_switchingToTouchAppliesToExistingControls() {
        const c = create(checkboxTip)
        ThemeManager.setDensity("touch")
        holdOn(c)
        tryCompare(tipIn(c), "opened", true)
        verify(!c.checked)
    }
}
