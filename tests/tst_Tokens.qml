import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

// The size tokens' defaults are the desktop values controls had as literals.
// Changing one changes every app on desktop; do it on purpose.
TestCase {
    id: tc
    name: "Tokens"
    width: 400
    height: 200
    when: windowShown

    function test_sizeScale() {
        const s = Theme.size
        compare(s.controlXSmall, 24)
        compare(s.controlSmall, 32)
        compare(s.controlMedium, 36)
        compare(s.controlLarge, 40)
        compare(s.controlXLarge, 44)
        compare(s.iconXSmall, 12)
        compare(s.iconSmall, 16)
        compare(s.iconMedium, 20)
        compare(s.borderWidth, 1)
        compare(s.focusWidth, 2)
        compare(s.touchTarget, 44)
    }

    function test_controlTokens_data() {
        return [
            { tag: "artwork",       group: "artwork",       values: { size: 40 } },
            { tag: "badge",         group: "badge",         values: { iconSize: 12, fontSize: 11, letterSpacing: 0.22 } },
            { tag: "button",        group: "button",        values: { height: 44, compactHeight: 32, paddingX: 16, compactPaddingX: 12, minWidth: 100, compactMinWidth: 72, iconSize: 20 } },
            { tag: "checkbox",      group: "checkbox",      values: { indicatorSize: 24 } },
            { tag: "combo",         group: "combo",         values: { height: 32, paddingX: 10, indicatorSize: 20, popupGap: 2 } },
            { tag: "copyButton",    group: "copyButton",    values: { size: 24, iconSize: 16 } },
            { tag: "dotMatrix",     group: "dotMatrix",     values: { dotSize: 8 } },
            { tag: "field",         group: "field",         values: { width: 200, height: 40, paddingX: 12 } },
            { tag: "icon",          group: "icon",          values: { size: 20 } },
            { tag: "iconButton",    group: "iconButton",    values: { size: 40, iconSize: 20 } },
            { tag: "infoButton",    group: "infoButton",    values: { size: 16, fontSize: 9, dialogWidth: 560 } },
            { tag: "listItem",      group: "listItem",      values: { height: 36, paddingX: 12 } },
            { tag: "menu",          group: "menu",          values: { width: 200 } },
            { tag: "menuItem",      group: "menuItem",      values: { height: 32, paddingX: 12 } },
            { tag: "notice",        group: "notice",        values: { iconPlateSize: 28, iconSize: 16, closeButtonSize: 20, closeIconSize: 12 } },
            { tag: "paginator",     group: "paginator",     values: { height: 36, buttonSize: 36, buttonMinWidth: 24, pageSizeMinWidth: 80, pageSizeWidth: 130 } },
            { tag: "progressBar",   group: "progressBar",   values: { width: 200, height: 8 } },
            { tag: "radio",         group: "radio",         values: { indicatorSize: 22, dotSize: 8 } },
            { tag: "scrollBar",     group: "scrollBar",     values: { thickness: 6 } },
            { tag: "search",        group: "search",        values: { width: 400, height: 54, paddingLeft: 10, iconSize: 20, clearButtonSize: 20, clearIconSize: 14, hintHeight: 20 } },
            { tag: "slider",        group: "slider",        values: { width: 200, trackHeight: 4, handleSize: 18 } },
            { tag: "spinBox",       group: "spinBox",       values: { height: 32, buttonWidth: 28 } },
            { tag: "spinner",       group: "spinner",       values: { size: 36, thickness: 3, dotSize: 6, dotInset: 2 } },
            { tag: "stageLane",     group: "stageLane",     values: { width: 200, height: 30, notch: 14, gap: 2, cornerRadius: 3 } },
            { tag: "statCard",      group: "statCard",      values: { minHeight: 108, iconSize: 16 } },
            { tag: "tab",           group: "tab",           values: { height: 40, paddingX: 8, spacing: 6, iconSize: 20, underlineHeight: 2 } },
            { tag: "tabBar",        group: "tabBar",        values: { indicatorHeight: 3 } },
            { tag: "table",         group: "table",         values: { rowHeight: 64, headerHeight: 36, columnMinWidth: 80, selectionColumnWidth: 40, sortIconWidth: 12, sortIconHeight: 8 } },
            { tag: "tile",          group: "tile",          values: { size: 40 } },
            { tag: "toggle",        group: "toggle",        values: { width: 40, height: 24, trackWidth: 36, trackHeight: 20 } },
            { tag: "toolButton",    group: "toolButton",    values: { size: 36 } },
            { tag: "toolSeparator", group: "toolSeparator", values: { length: 24 } },
            { tag: "toolTip",       group: "toolTip",       values: { height: 20, paddingX: 6, paddingY: 2 } },
            { tag: "warningDialog", group: "warningDialog", values: { iconSize: 18 } },
        ]
    }

    function test_controlTokens(data) {
        const group = Theme.controls[data.group]
        verify(group, "Theme.controls." + data.group + " is missing")
        for (const key in data.values)
            fuzzyCompare(group[key], data.values[key], 0.0001, data.group + "." + key)
    }

    LogosButton { id: button; text: "Go" }
    LogosButton { id: compactButton; text: "Go"; compact: true }
    LogosTextField { id: field }
    LogosSwitch { id: toggle }
    LogosIconButton { id: iconButton }

    // Controls take their size from the tokens.
    function test_controlsReadTheirTokens() {
        compare(button.implicitHeight, Theme.controls.button.height)
        compare(compactButton.implicitHeight, Theme.controls.button.compactHeight)
        compare(field.implicitHeight, Theme.controls.field.height)
        compare(field.leftPadding, Theme.controls.field.paddingX)
        compare(toggle.indicator.implicitWidth, Theme.controls.toggle.width)
        compare(iconButton.size, Theme.controls.iconButton.size)
    }
}
