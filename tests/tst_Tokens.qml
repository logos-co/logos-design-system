import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import LogosTests

// The size tokens' defaults are the desktop values controls had as literals.
// Changing one changes every app on desktop; do it on purpose.
TestCase {
    id: tc
    name: "Tokens"
    width: 400
    height: 200
    when: windowShown

    function cleanup() {
        Theme.viewWidth = 0
        ThemeManager.setDensity("")
    }

    function typeScale() {
        const t = Theme.typography
        return [t.mainTitleText, t.displayText, t.pageTitleText, t.titleText, t.panelTitleText,
                t.subtitleText, t.primaryText, t.secondaryText, t.badgeText]
    }

    function test_typeScale() {
        compare(typeScale(), [256, 40, 36, 30, 24, 16, 14, 12, 8])
    }

    function test_titlesStepDownInAPhoneWideView() {
        Theme.viewWidth = 390
        compare(typeScale(), [96, 28, 28, 24, 20, 16, 14, 12, 10])
        Theme.viewWidth = 700
        compare(typeScale(), [256, 40, 36, 30, 24, 16, 14, 12, 8])
    }

    function test_badgeTextGrowsAtTouchDensity() {
        ThemeManager.setDensity("touch")
        compare(typeScale(), [256, 40, 36, 30, 24, 16, 14, 12, 10])
    }

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
            { tag: "button",        group: "button",        values: { height: 44, compactHeight: 32, paddingX: 16, compactPaddingX: 12, paddingY: 12, compactPaddingY: 8, minWidth: 100, compactMinWidth: 72, iconSize: 20 } },
            { tag: "buttonRow",     group: "buttonRow",     values: { minButtonWidth: 140 } },
            { tag: "checkbox",      group: "checkbox",      values: { indicatorSize: 24 } },
            { tag: "combo",         group: "combo",         values: { height: 32, paddingX: 10, indicatorSize: 20, popupGap: 2 } },
            { tag: "copyButton",    group: "copyButton",    values: { size: 24, iconSize: 16 } },
            { tag: "dialog",        group: "dialog",        values: { handleWidth: 32, handleHeight: 4, sheetTopGap: 44 } },
            { tag: "dotMatrix",     group: "dotMatrix",     values: { dotSize: 8 } },
            { tag: "field",         group: "field",         values: { width: 200, height: 40, paddingX: 12 } },
            { tag: "icon",          group: "icon",          values: { size: 20 } },
            { tag: "iconButton",    group: "iconButton",    values: { size: 40, iconSize: 20 } },
            { tag: "infoButton",    group: "infoButton",    values: { size: 16, fontSize: 9, dialogWidth: 560 } },
            { tag: "listItem",      group: "listItem",      values: { height: 36, paddingX: 12 } },
            { tag: "listRow",       group: "listRow",       values: { height: 52, subtitleHeight: 64, paddingX: 16, iconSize: 20 } },
            { tag: "menu",          group: "menu",          values: { width: 200 } },
            { tag: "menuItem",      group: "menuItem",      values: { height: 32, paddingX: 12 } },
            { tag: "notice",        group: "notice",        values: { iconPlateSize: 28, iconSize: 16, closeButtonSize: 20, closeIconSize: 12 } },
            { tag: "paginator",     group: "paginator",     values: { height: 36, buttonSize: 36, buttonMinWidth: 24, pageSizeMinWidth: 80, pageSizeWidth: 130 } },
            { tag: "progressBar",   group: "progressBar",   values: { width: 200, height: 8 } },
            { tag: "radio",         group: "radio",         values: { indicatorSize: 22, dotSize: 8 } },
            { tag: "scrollBar",     group: "scrollBar",     values: { thickness: 6 } },
            { tag: "search",        group: "search",        values: { width: 400, height: 54, paddingLeft: 10, iconSize: 20, clearButtonSize: 20, clearIconSize: 14, hintHeight: 20 } },
            { tag: "searchToggle",  group: "searchToggle",  values: { fieldWidth: 280 } },
            { tag: "slider",        group: "slider",        values: { width: 200, trackHeight: 4, handleSize: 18 } },
            { tag: "spinBox",       group: "spinBox",       values: { height: 32, buttonWidth: 28 } },
            { tag: "spinner",       group: "spinner",       values: { size: 36, thickness: 3, dotSize: 6, dotInset: 2 } },
            { tag: "stageLane",     group: "stageLane",     values: { width: 200, height: 30, notch: 14, gap: 2, cornerRadius: 3 } },
            { tag: "stateView",     group: "stateView",     values: { maxWidth: 400, iconSize: 40 } },
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

    function test_layoutTokens_data() {
        return [
            { tag: "cardGrid",   group: "cardGrid",   values: { maximumWidth: 1200, statCardWidth: 150, tileWidthPhone: 104, tileWidthTablet: 140, tileWidthDesktop: 180 } },
            { tag: "cardPair",   group: "cardPair",   values: { minimumMainWidth: 400, minimumSideWidth: 220 } },
            { tag: "form",       group: "form",       values: { maximumWidth: 720, labelWidth: 200 } },
            { tag: "itemLayout", group: "itemLayout", values: { minimumContentWidth: 120, lineSpacing: 4 } },
            { tag: "listDetail", group: "listDetail", values: { tabletListWidth: 320, desktopListWidth: 360 } },
            { tag: "pageBar",    group: "pageBar",    values: { height: 56, phoneHeight: 44 } },
            { tag: "sections",   group: "sections",   values: { listWidth: 200, tabletListWidth: 168 } },
            { tag: "sidebarLayout", group: "sidebarLayout", values: { sideWidth: 200, minimumContentWidth: 560 } },
            { tag: "sidePanel",  group: "sidePanel",  values: { width: 320 } },
            { tag: "welcome",    group: "welcome",    values: { maximumWidth: 520, buttonWidth: 320, buttonHeight: 48, logoSize: 48 } },
            { tag: "wizard",     group: "wizard",     values: { railHeight: 4, railLabelText: 11, nextMinWidth: 160 } },
        ]
    }

    function test_layoutTokens(data) {
        const group = Theme.layouts[data.group]
        verify(group, "Theme.layouts." + data.group + " is missing")
        for (const key in data.values)
            compare(group[key], data.values[key], data.group + "." + key)
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
