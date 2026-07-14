import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosButton"
    width: 400
    height: 200
    when: windowShown

    LogosButton {
        id: btn
        text: "Click me"
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
        btn.text = "Click me"
        btn.isPrimary = false
        btn.iconSource = ""
        btn.iconPosition = "left"
    }

    function test_renders_text() {
        compare(btn.text, "Click me")
    }

    function test_text_setter_updates_label() {
        btn.text = "Updated"
        compare(btn.text, "Updated")
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

    function test_neutral_by_default() {
        compare(btn.isPrimary, false)
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundSecondary)
    }

    function test_primary_uses_primary_background() {
        btn.isPrimary = true
        tryCompare(btn.backgroundItem, "color", Theme.palette.primary)
    }

    function test_disabled_wins_over_primary() {
        btn.isPrimary = true
        btn.enabled = false
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundMuted)
        compare(btn.labelItem.color, Theme.palette.textMuted)
    }

    function test_icon_empty_by_default() {
        compare(btn.iconSource.toString(), "")
    }

    function test_icon_source_round_trips() {
        btn.iconSource = "qrc:/test-icon.png"
        compare(btn.iconSource.toString(), "qrc:/test-icon.png")
        btn.iconSource = ""
        compare(btn.iconSource.toString(), "")
    }

    function test_icon_anchors_left() {
        btn.iconSource = "qrc:/test-icon.png"
        btn.iconPosition = "left"
        tryVerify(function () { return btn.iconItem.x < btn.iconItem.parent.width / 2 })
    }

    function test_icon_anchors_right() {
        btn.iconSource = "qrc:/test-icon.png"
        btn.iconPosition = "right"
        tryVerify(function () { return btn.iconItem.x > btn.iconItem.parent.width / 2 })
    }

    function test_icon_tint_follows_content_color() {
        btn.iconSource = "qrc:/test-icon.png"
        compare(btn.iconItem.color, btn.contentColor)
    }
}
