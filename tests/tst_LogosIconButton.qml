import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosIconButton"
    width: 400
    height: 200
    when: windowShown

    LogosIconButton {
        id: btn
        iconSource: "qrc:/test-icon.png"
        anchors.centerIn: parent
    }

    SignalSpy {
        id: clickedSpy
        target: btn
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        btn.enabled = true
        btn.iconSource = "qrc:/test-icon.png"
        btn.size = 40
        btn.iconSize = 20
    }

    function test_iconSource_round_trips() {
        btn.iconSource = "qrc:/test-icon.png"
        compare(btn.iconSource.toString(), "qrc:/test-icon.png")
    }

    function test_iconSource_can_be_cleared() {
        btn.iconSource = ""
        compare(btn.iconSource.toString(), "")
    }

    function test_size_drives_implicit_dimensions() {
        btn.size = 32
        compare(btn.implicitWidth, 32)
        compare(btn.implicitHeight, 32)
    }

    function test_iconSize_drives_image_dimensions() {
        btn.iconSize = 24
        compare(btn.iconImage.width, 24)
        compare(btn.iconImage.height, 24)
    }

    function test_emits_clicked_when_enabled() {
        btn.mouseAreaItem.clicked(null)
        compare(clickedSpy.count, 1)
    }

    function test_disabled_propagates_to_mousearea() {
        btn.enabled = false
        compare(btn.mouseAreaItem.enabled, false)
        btn.enabled = true
        compare(btn.mouseAreaItem.enabled, true)
    }

    function test_inspection_aliases_resolve() {
        verify(btn.iconImage, "iconImage must resolve")
        verify(btn.backgroundItem, "backgroundItem must resolve")
        verify(btn.mouseAreaItem, "mouseAreaItem must resolve")
    }

    function test_active_colors_when_pressed() {
        mousePress(btn)
        compare(btn.backgroundItem.color, Theme.palette.backgroundMuted)
        compare(btn.backgroundItem.border.color, Theme.palette.overlayOrange)
        mouseRelease(btn)
        compare(btn.backgroundItem.color, Theme.palette.backgroundButton)
        compare(btn.backgroundItem.border.color, Theme.palette.borderStrong)
    }
}
