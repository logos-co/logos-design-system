import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosTabButton"
    width: 600
    height: 80
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
}
