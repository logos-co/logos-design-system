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
        btn.variant = LogosButton.Variant.Secondary
        btn.icon.source = ""
        btn.icon.position = LogosButton.IconPosition.Left
        btn.icon.color = Theme.palette.text
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
        compare(btn.variant, LogosButton.Variant.Secondary)
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundSecondary)
    }

    function test_primary_uses_primary_background() {
        btn.variant = LogosButton.Variant.Primary
        tryCompare(btn.backgroundItem, "color", Theme.palette.primary)
    }

    function test_disabled_wins_over_primary() {
        btn.variant = LogosButton.Variant.Primary
        btn.enabled = false
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundMuted)
        compare(btn.labelItem.color, Theme.palette.textMuted)
    }

    function test_icon_empty_by_default() {
        compare(btn.icon.source.toString(), "")
    }

    function test_icon_source_round_trips() {
        btn.icon.source = "qrc:/test-icon.png"
        compare(btn.icon.source.toString(), "qrc:/test-icon.png")
        btn.icon.source = ""
        compare(btn.icon.source.toString(), "")
    }

    function test_icon_shows_on_left() {
        btn.icon.source = "qrc:/test-icon.png"
        btn.icon.position = LogosButton.IconPosition.Left
        var slots = btn.contentItem.children
        compare(slots[0].opacity, 1)
        compare(slots[slots.length - 1].opacity, 0)
    }

    function test_icon_shows_on_right() {
        btn.icon.source = "qrc:/test-icon.png"
        btn.icon.position = LogosButton.IconPosition.Right
        var slots = btn.contentItem.children
        compare(slots[slots.length - 1].opacity, 1)
        compare(slots[0].opacity, 0)
    }

    function test_icon_tint_follows_icon_color() {
        btn.icon.source = "qrc:/test-icon.png"
        btn.icon.color = Theme.palette.primary
        compare(btn.iconItem.color, Theme.palette.primary)
    }

    function test_long_text_is_elided() {
        btn.text = "This is a very long label that will not fit inside the button width"
        tryCompare(btn.labelItem, "truncated", true)
        verify(btn.labelItem.width <= btn.width)
    }
}
